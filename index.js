const express = require('express');
const jwt = require('jsonwebtoken');
require('dotenv').config();
const cors = require('cors');
const mysql = require('mysql');
const bodyParser = require('body-parser');
const app = express()
app.use(cors())
app.use(bodyParser.json({limit: '10mb'}))
const moment = require('moment');
const secret = process.env.SECRET

app.get('/', function(req, res){
    res.send('Primera ruta de la Api')
})

const credentials = {
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'tienda_web'
}


app.get('/usuarios', (req, res) => {
    var connection = mysql.createConnection(credentials)
    connection.query('SELECT * FROM credenciales', (err, result) => {
        if (err)
            res.status(500).send(err)
        else
            res.status(200).send(result)
    })
    connection.end()
})

app.get('/token', (req, res) => {
    try{
        const token = req.headers.authorization.split(' ')[1]
        if (token === undefined)
            return res.send('error');
        const payload = jwt.verify(token, secret)
        if(Date.now() > payload.exp){
            return res.send("error")
        }
        res.send('existe')
    } catch (error) {
        res.send({ error: error.message})
    }
})


app.post('/login', (req, res) => {
    const {username, password} = req.body
    const values = [username, password]
    var connection = mysql.createConnection(credentials)
    connection.query("select * from credenciales where usuario = ? and contraseña = ?", values, (err, result) => {
        if(err){
            res.status(500).send(err)
        }else{
            if(result.length > 0){
                const token = jwt.sign({
                    username,
                    exp: Date.now() + 1440 * 1000
                }, secret)

                res.status(200).send({token})
            }else{
                res.send('false')
            }
        }
    })
    connection.end()
})


app.post('/updateUser', (req, res) => {
    try{
        const token = req.headers.authorization.split(' ')[1]
        if (token === undefined)
            return res.send('error1');
        const payload = jwt.verify(token, secret)

        if(Date.now() > payload.exp){
            return res.send("error1");
        }
        const { newPassword, passwordActual } = req.body;
        const values = [newPassword, payload.username, passwordActual];
        var connection = mysql.createConnection(credentials);
        // Codigo a ejecutar despues de verificar
        try{
            connection.query('UPDATE credenciales SET contraseña = ? WHERE usuario = ? and contraseña = ?;', values, (err, result) => {
                connection.end(); // Cerrar la conexión después de completar todas las consultas
    
                if (err)
                    res.send('error2');
                else{
                    if(result.affectedRows > 0)
                        res.status(200).send('exito');
                    else
                        res.send('error2');
                }
            })
        }
        catch{
            res.send('error2');
        }
    } catch (error) {
        res.send(error);
    }
});


app.post('/register', (req, res) => {
    const { username, password } = req.body;
    const values = [username, password];
    var connection = mysql.createConnection(credentials);

    connection.query('call new_client(?,?);', values, (err, result) => {
        connection.end(); // Cerrar la conexión
        if (err)
            res.status(500).send('existe');
        if (result[0][0].mensaje === 'existe')
            res.status(500).send('existe');
        else{
            const token = jwt.sign({
                username,
                exp: Date.now() + 600 * 1000
            }, secret);
            res.status(200).send({ token });
        }
    });
});



app.post('/deleteUser', (req, res) => {
    try{
        const token = req.headers.authorization.split(' ')[1]
        if (token === undefined)
            return res.send('error1');
        const payload = jwt.verify(token, secret)

        if(Date.now() > payload.exp){
            return res.send('error1');
        }
        const body = req.body;
        const values = [payload.username, body.password];
        var connection = mysql.createConnection(credentials);
        // Codigo a ejecutar despues de verificar
        try{
            connection.query('call delete_client(?,?);', values, (err, result) => {
                connection.end(); // Cerrar la conexión
                if (err)
                    res.send('error2');
                else if (result[0][0].mensaje === 'inexistente')
                    res.send('inexistente');
                else if (result[0][0].mensaje === 'correcto')
                    res.send('correcto');
            })
        }
        catch{
            res.send('error2');
        }

    } catch (error) {
        res.send(error);
    }
});




app.post('/cargar-venta', (req, res) => {
    try{
        // const shoppingHistory = ['(Motorola Moto E13 64gb 2gb Ram Azul Turquesa)','(Samsung Galaxy A04e 64 GB negro 3 GB RAM)','(Google Pixel 6a)']
        const token = req.headers.authorization.split(' ')[1]
        if (token === undefined)
            return res.send('error1');
        const payload = jwt.verify(token, secret)

        if(Date.now() > payload.exp){
            return res.send('error1');
        }

        const { shoppingHistory, total } = req.body;

        var connection1 = mysql.createConnection(credentials);
        var connection2 = mysql.createConnection(credentials);


        
        // Obtener la fecha y hora actual
        const fechaHoraActual = moment().format('YYYY-MM-DD HH:mm:ss');
        
        
        const venta = [payload.username, fechaHoraActual, total];

        let consulta = 'insert into tienda_web.productos_vendidos (id_venta, nombre, precio, cantidad) values '
        
        connection1.query('call cargar_venta(?,?,?)', venta, (err, result) => {
            connection1.end(); // Cerrar la conexión
            if (err)
                res.send("error2");
            else if (result[0][0].mensaje === 'inexistente')
                res.send('inexistente');
            else{
                let count = 1
                for (product of shoppingHistory){
                    consulta += ("(" + result[0][0].mensaje + "," + product)
                    if(count < shoppingHistory.length){
                        consulta += ","
                    }
                
                    count++;
                }
                connection2.query(consulta, (err, result) => {
                    connection2.end(); // Cerrar la conexión
                    if (err)
                        res.send("error2");
                    else
                        res.send("correcto");
                })
            }
        });
        
    }catch (error) {
        res.send({ error: error.message});
    }
});



app.get('/get_purchases', (req, res) => {
    const token = req.headers.authorization.split(' ')[1]
    if (token === undefined)
        return res.send('inexistente');
    const payload = jwt.verify(token, secret)

    if(Date.now() > payload.exp){
        return res.send('inexistente');
    }

    var connection = mysql.createConnection(credentials)
    connection.query('call get_purchases(?)', payload.username,(err, result) => {
        connection.end()
        if (err)
            res.send(err)
        else if(result[0][0])
            if(result[0][0].mensaje === 'inexistente')
                res.send("inexistente")
        else{
            res.send(result)
        }
    })
});



app.post('/get_purchasing_details', (req, res) => {
    try{
        const token = req.headers.authorization.split(' ')[1]
        if (token === undefined)
            return res.send('inexistente');
        const payload = jwt.verify(token, secret)
    
        if(Date.now() > payload.exp){
            return res.send('inexistente');
        }
        var connection = mysql.createConnection(credentials)
        connection.query('call get_purchasing_details(?)', req.body.id_venta, (err, result) => {
            connection.end()
            if (err)
                res.send(err)
            else if(result[0][0])
                if(result[0][0].mensaje === 'inexistente')
                    res.send("inexistente")
            else{
                res.send(result)
            }
        })
    }
    catch(error){
        console.log(error)
    }
});

app.use('/imagenes', express.static('./imagenes'));


app.get('/productos', (req, res) => {
    var connection = mysql.createConnection(credentials)
    connection.query('SELECT * FROM productos', (err, result) => {
        connection.end()
        if (err)
            res.status(500).send(err)
        else
            res.status(200).send(result)
    })
})


app.listen('5000', () =>{
    console.log('Aplicación iniciada en el puerto 5000')
})

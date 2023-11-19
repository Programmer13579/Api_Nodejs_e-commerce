/* 
   **********************************
   *   CREACION DE BASE DE DATOS    *
   **********************************
*/ 
create database if not exists tienda_web;

use tienda_web;

/* 
   **********************************
   *    ELIMINACION DE LAS TABLAS   *
   **********************************
*/ 

drop table if exists productos_vendidos;
drop table if exists ventas;
drop table if exists credenciales;
drop table if exists productos;

/* 
   **********************************
   *   	 CREACION DE LAS TABLAS     *
   **********************************
*/ 

create table credenciales(
	`id` int NOT NULL AUTO_INCREMENT PRIMARY KEY unique,
    `usuario` varchar(45) NOT NULL,
    `contraseña` varchar(45) NOT NULL
);

CREATE TABLE productos (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY unique,
  `categoria` varchar(50) NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `precio` float NOT NULL,
  `descripcion` varchar(1000) DEFAULT NULL,
  `urlImage` varchar(100) NOT NULL,
  `stock` float NOT NULL
);

CREATE TABLE ventas (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY unique,
  `usuario` varchar(45) not null,
  `fecha` datetime NOT NULL,
  `total` float NOT NULL,
  `id_usuario` int not null,
  FOREIGN KEY (id_usuario) REFERENCES credenciales(id)
);

CREATE TABLE productos_vendidos (
  `id` int NOT NULL AUTO_INCREMENT PRIMARY KEY unique,
  `id_venta` int NOT NULL,
  `nombre` varchar(150) NOT NULL,
  `precio` float NOT NULL,
  `cantidad` float NOT NULL,
  FOREIGN KEY (id_venta) REFERENCES ventas(id)
);

/* 
   **********************************
   *   PROCEDIMIENTOS ALMACENADOS   *
   **********************************
*/ 

drop procedure if exists new_client;


DELIMITER //

CREATE PROCEDURE new_client (
	p_usuario VARCHAR(45),
    p_password VARCHAR(45)
)
BEGIN
    DECLARE v_count INT;
    DECLARE v_mensaje VARCHAR(100);

    -- Verificar si el usuario existe
    SELECT COUNT(*) INTO v_count FROM tienda_web.credenciales WHERE usuario = p_usuario;

    IF v_count = 0 THEN
        -- Insertar en la tabla credenciales utilizando el ID del cliente
        INSERT INTO tienda_web.credenciales (usuario, contraseña) VALUES (p_usuario, p_password);
        
        SET v_mensaje ='correcto';
    ELSE
        SET v_mensaje = 'existe';
    END IF;
    -- Devolver el mensaje como resultado
    SELECT v_mensaje AS mensaje;
END //

DELIMITER ;






drop procedure if exists delete_client;


DELIMITER //

CREATE PROCEDURE delete_client (
	p_usuario VARCHAR(45),
    p_password VARCHAR(45)
)
BEGIN
    DECLARE cliente_Id INT;
    DECLARE v_mensaje VARCHAR(100);

    -- Verificar si el usuario existe
	SELECT id INTO cliente_Id FROM tienda_web.credenciales WHERE usuario = p_usuario and contraseña = p_password;

    IF cliente_Id != 0 THEN
        -- Si el usuario existe eliminarlo de la tabla credenciales y de la tabla clientes
        delete from tienda_web.credenciales where id = cliente_Id;
        
        SET v_mensaje ='correcto';
    ELSE
        SET v_mensaje = 'inexistente';
    END IF;
    -- Devolver el mensaje como resultado
    SELECT v_mensaje AS mensaje;

END //

DELIMITER ;





drop procedure if exists cargar_venta;


DELIMITER //

CREATE PROCEDURE cargar_venta (
	v_usuario VARCHAR(45),
    v_fecha datetime,
    v_total float
)
BEGIN
	DECLARE v_cliente_id INT;
    DECLARE v_id INT;
    DECLARE v_mensaje VARCHAR(100);

    -- Verificar si el usuario existe
    SELECT id INTO v_id FROM tienda_web.credenciales WHERE usuario = v_usuario;

    IF v_id <> 0 THEN
        -- Insertar en la tabla credenciales utilizando el ID del cliente
        INSERT INTO tienda_web.ventas (usuario, fecha, total, id_usuario) VALUES (v_usuario, v_fecha, v_total, v_id);
        -- Obtener el ID del cliente agregado
        SET v_cliente_id = LAST_INSERT_ID();
        
        SET v_mensaje =v_cliente_id;
    ELSE
        SET v_mensaje = 'inexistente';
    END IF;
    -- Devolver el mensaje como resultado
    SELECT v_mensaje AS mensaje;
END //

DELIMITER ;





drop procedure if exists get_purchases;


DELIMITER //

CREATE PROCEDURE get_purchases (
	v_usuario VARCHAR(45)
)
BEGIN
	DECLARE v_cliente_id INT;
    DECLARE v_id INT;
    DECLARE v_mensaje VARCHAR(100);

    -- Verificar si el usuario existe
    SELECT id INTO v_id FROM tienda_web.credenciales WHERE usuario = v_usuario;

    IF v_id <> 0 THEN
		SELECT * FROM tienda_web.ventas WHERE id_usuario = v_id;
    ELSE
        SET v_mensaje = 'inexistente';
        -- Devolver el mensaje como resultado
		SELECT v_mensaje AS mensaje;
    END IF;
END //

DELIMITER ;





drop procedure if exists get_purchasing_details;


DELIMITER //

CREATE PROCEDURE get_purchasing_details (
	v_idVenta VARCHAR(45)
)
BEGIN
	DECLARE v_cliente_id INT;
    DECLARE v_id INT;
    DECLARE v_mensaje VARCHAR(100);

    -- Verificar si la compra existe
    SELECT id INTO v_id FROM tienda_web.ventas WHERE id = v_idVenta;

    IF v_id <> 0 THEN
		SELECT * FROM tienda_web.productos_vendidos WHERE id_venta = v_idVenta;
    ELSE
        SET v_mensaje = 'inexistente';
        -- Devolver el mensaje como resultado
		SELECT v_mensaje AS mensaje;
    END IF;
END //

DELIMITER ;





select * from credenciales;
select * from ventas;
select * from productos_vendidos;


/* 
   **********************************
   *   EJECUCION DE PROCEDIMIENTOS  *
   **********************************
*/ 

call new_client('user2', 'password');

call delete_client('user2', 'password');


INSERT INTO `tienda_web`.`productos`
(`categoria`,
`nombre`,
`precio`,
`descripcion`,
`urlImage`,
`stock`)
VALUES
("todos ofertas celulares","Motorola Moto E13 64gb 2gb Ram Azul Turquesa", 59990,"El celular Motorola Moto E13 cuenta con un diseño sofisticado y espectacular. Obtén el estilo que estabas esperando con el moto e13. Su diseño delgado te proporciona una experiencia audiovisual multidimensional con audio Dolby Atmos y una pantalla ultraamplia HD+ de 6.5.","imagen_1.webp",1),
("todos ofertas celulares","Samsung Galaxy A04e 64 GB negro 3 GB RAM", 84499,"Doble cámara y más detalles. Sus 2 cámaras traseras de 13 Mpx/2 Mpx te permitirán tomar imágenes con más detalles y lograr efectos únicos como el famoso modo retrato de poca profundidad de campo. Además, el dispositivo cuenta con cámara frontal de 5 Mpx para que puedas sacarte divertidas selfies o hacer videollamadas.","imagen_2.webp",1),
("todos ofertas celulares","Google Pixel 6a", 322344,"Google Tensor hace que el Pixel 6a sea un dispositivo más inteligente, seguro y potente. Es el primer chip diseñado por Google solo para el Pixel.La Batería adaptable del Pixel puede durar más de 24 horas. Se adapta a ti al identificar tus apps favoritas para no desperdiciar energía en las que menos usas.Con el Borrador mágico y Google Fotos, puedes quitar distracciones fácilmente, como las personas que aparecen en las fotos2. O cambiar el color y el brillo de un objeto para que se combine con el resto. ","imagen_11.webp",1),
("todos ofertas celulares","Google Pixel 7", 544233,"Cuenta con un interior robusto y un armazón que rinde homenaje a lo moderno. Está construido con materiales de primera calidad y presenta un elegante diseño. Además, la pantalla OLED de 6.3 pulgadas con resolución FHD tiene una tasa de refresco de 90 Hz que se adapta a la jerarquía de los teléfonos más avanzados. ","imagen_12.webp",1),
("todos celulares","Google Pixel 7 Pro", 844992,"El Google Pixel 7 Pro 12/128GB Blanco es el camino a seguir si deseas obtener la mejor experiencia móvil. Está equipado con una potente pantalla de 6.7 pulgadas Smooth Display que se ajusta hasta los 120Hz, para ofrecerte una experiencia de juego y contenidos de mayor calidad. Esta pantalla es una maravilla para la visualización de imágenes ya que ofrece una increíble nitidez y un efecto 3D. ","imagen_13.webp",1),
("todos celulares","Google Pixel 7a", 970543,"Resistente a salpicaduras, polvo y arañazos. Una increíble pantalla fluida de 6,1 pulgadas. Pixel 7a está disponible en cuatro colores llamativos. Además, se ha fabricado con aluminio, vidrio y plástico reciclados.","imagen_14.webp",1),
("todos celulares","Google Pixel 8", 1006455,"Diseñado con el chip más avanzado de Pixel y la IA de Google para ayudarte a hacer más sin esfuerzo.Pantalla Actua, nítida y clara incluso con luz solar directa.","imagen_15.webp",1),
("todos celulares","Google Pixel 8 Pro", 1234345,"Con la IA de Google y la mejor Cámara Pixel, es el Pixel más potente y personal hasta la fecha.Cámaras totalmente renovadas y funciones de edición nunca vistas.l nuevo chip Google Tensor G3 se ha diseñado a medida con la IA de Google para ofrecerte funciones vanguardistas de fotografía y vídeo, así como formas más inteligentes de ayudarte a lo largo del día.","imagen_16.webp",1),

("todos ofertas Componentes","Disco Solido Ssd 1tb M.2 Kingston Snv2s/1000g Nvme Pcie 4.0", 59075,"Líder en el mercado de tecnologías, Kingston ofrece una gran variedad de dispositivos de almacenamiento. Su calidad y especialización en discos de estado sólido (SSD), de memoria y de USB cifrados la convierten una de las opciones más elegidas en el mercado internacional.","imagen_3.webp",1),
("todos ofertas Componentes","Memoria Ram Fury Beast Ddr4 Gamer Color Negro 16gb 1 Kingston Kf432c16bb/16", 38818,"Mejora tu experiencia de juego con la Memoria RAM Fury Beast de Kingston, diseñada especialmente para gamers. Con una capacidad de 16 GB y una velocidad de 3200 MHz, esta memoria DDR4 SDRAM te permitirá disfrutar de tus juegos favoritos sin interrupciones ni demoras. Su formato UDIMM y sus 288 pines aseguran una fácil instalación y compatibilidad con sistemas AMD e Intel.","imagen_4.webp",1),
("todos ofertas Componentes","Procesador Amd Ryzen 5 5600g Con Video 4.4ghz Box Garantia", 199999,"ESPECIFICACIONES. -- N.° de núcleos de CPU: 6. -- N.° de subprocesos: 12. -- N.° de núcleos de GPU: 7. -- Reloj base: 3.9GHz. -- Reloj de aumento máx.: Hasta 4.4GHz. -- Caché L2 total: 3MB. -- Caché L3 total: 16MB. -- Desbloqueados: Sí. -- CMOS: TSMC 7nm FinFET. -- Paquete: AM4. -- Versión de PCI Express: PCIe 3.0. -- Solución térmica: Wraith Stealth. -- TDP/TDP predeterminado: 65W. -- cTDP: 45-65W. -- Temp. máx.: 95°C","imagen_5.webp",1),
("todos ofertas impresoras","Impresora Brother HL-1 Series HL-1212W -", 164880,"La Brother HL1212W es una impresora láser monocromática de alto rendimiento, ideal para uso doméstico y pequeñas oficinas. Con su diseño compacto en color negro y blanco, se adapta perfectamente a cualquier espacio de trabajo. Gracias a su tecnología láser, podrás disfrutar de impresiones de alta calidad y nitidez en todos tus documentos.","imagen_6.webp",1),
("todos ofertas impresoras","Impresora a color multifunción Epson EcoTank L3210 negra 220V", 379080,"Epson busca que sus clientes obtengan el máximo provecho de sus productos. Por ello, brinda soluciones de impresión con una amplia gama de dispositivos que cubren todos los usos y necesidades, tanto en casa como en el trabajo. Eficiencia y calidad. Imprimí archivos, escaneá documentos y hacé todas las fotocopias que necesités con esta impresora multifunción Epson, siempre lista para facilitar tu rutina de trabajo o estudio.","imagen_7.webp",1),
("todos ofertas tablets","Tablet Philco Tp10a332 10.1'' Ips 32gb 2gb Android 11", 76074,"¡Experimentá el futuro de la tecnología en tus manos con la increíble Tablet Philco! Disfrutá de tus películas, juegos y contenido favorito en una vibrante pantalla de 10 pulgadas con colores nítidos y realistas. Equipada con un procesador de alto rendimiento y amplia memoria RAM, te garantiza un rendimiento fluido y multitarea sin esfuerzo. Con una amplia capacidad de almacenamiento interno y soporte para tarjetas microSD, tendrás espacio más que suficiente para guardar tus archivos, fotos y videos. ","imagen_8.webp",1),
("todos ofertas tablets","Tablet Galaxy Tab A8 Wifi 10.5'' 64gb - Pantalla Inmersiva Color Silver", 204989,"La Tablet Galaxy Tab A8 Wifi 10.5'' 64gb - Pantalla Inmersiva Color Silver cuenta con una pantalla de 10,5' de ancho y un marco simétrico de solo 10,2 mm, ideal para sumergirte en tus contenidos favoritos.","imagen_9.webp",1),
("todos ofertas tablets","Tablet Galaxy Tab A8 Wifi 10.5'' 64gb - Pantalla Inmersiva Color Gray", 204989,"La Tablet Galaxy Tab A8 Wifi 10.5'' 64gb - Pantalla Inmersiva Color Gray es un dispositivo que te permitirá sumergirte en tus contenidos favoritos gracias a su pantalla de 10,5' de ancho con un marco simétrico de solo 10,2 mm. Su diseño combina un toque juvenil y fresco con la elegancia de su cuerpo metálico y un perfil ultrafino de tan solo 6,9 mm, características propias de las tablets Samsung.","imagen_10.webp",1);



insert into credenciales (usuario, contraseña) values ('user', 'password');

select * from credenciales;
-- select * from productos;
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

drop table if exists comentarios;
drop table if exists credenciales;
drop table if exists notificaciones;
drop table if exists clientes;
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
("ofertas celulares","Motorola Moto E13 64gb 2gb Ram Azul Turquesa", 59990,"El celular Motorola Moto E13 cuenta con un diseño sofisticado y espectacular. Obtén el estilo que estabas esperando con el moto e13. Su diseño delgado te proporciona una experiencia audiovisual multidimensional con audio Dolby Atmos y una pantalla ultraamplia HD+ de 6.5.","imagen_1.webp",1),
("ofertas celulares","Samsung Galaxy A04e 64 GB negro 3 GB RAM", 84499,"Doble cámara y más detalles. Sus 2 cámaras traseras de 13 Mpx/2 Mpx te permitirán tomar imágenes con más detalles y lograr efectos únicos como el famoso modo retrato de poca profundidad de campo. Además, el dispositivo cuenta con cámara frontal de 5 Mpx para que puedas sacarte divertidas selfies o hacer videollamadas.","imagen_2.webp",1),
("ofertas Componentes","Disco Solido Ssd 1tb M.2 Kingston Snv2s/1000g Nvme Pcie 4.0", 59075,"Líder en el mercado de tecnologías, Kingston ofrece una gran variedad de dispositivos de almacenamiento. Su calidad y especialización en discos de estado sólido (SSD), de memoria y de USB cifrados la convierten una de las opciones más elegidas en el mercado internacional.","imagen_3.webp",1),
("ofertas Componentes","Memoria Ram Fury Beast Ddr4 Gamer Color Negro 16gb 1 Kingston Kf432c16bb/16", 38818,"Mejora tu experiencia de juego con la Memoria RAM Fury Beast de Kingston, diseñada especialmente para gamers. Con una capacidad de 16 GB y una velocidad de 3200 MHz, esta memoria DDR4 SDRAM te permitirá disfrutar de tus juegos favoritos sin interrupciones ni demoras. Su formato UDIMM y sus 288 pines aseguran una fácil instalación y compatibilidad con sistemas AMD e Intel.","imagen_4.webp",1),
("ofertas Componentes","Procesador Amd Ryzen 5 5600g Con Video 4.4ghz Box Garantia", 199999,"ESPECIFICACIONES. -- N.° de núcleos de CPU: 6. -- N.° de subprocesos: 12. -- N.° de núcleos de GPU: 7. -- Reloj base: 3.9GHz. -- Reloj de aumento máx.: Hasta 4.4GHz. -- Caché L2 total: 3MB. -- Caché L3 total: 16MB. -- Desbloqueados: Sí. -- CMOS: TSMC 7nm FinFET. -- Paquete: AM4. -- Versión de PCI Express: PCIe 3.0. -- Solución térmica: Wraith Stealth. -- TDP/TDP predeterminado: 65W. -- cTDP: 45-65W. -- Temp. máx.: 95°C","imagen_5.webp",1),
("ofertas impresoras","Impresora Brother HL-1 Series HL-1212W -", 164880,"La Brother HL1212W es una impresora láser monocromática de alto rendimiento, ideal para uso doméstico y pequeñas oficinas. Con su diseño compacto en color negro y blanco, se adapta perfectamente a cualquier espacio de trabajo. Gracias a su tecnología láser, podrás disfrutar de impresiones de alta calidad y nitidez en todos tus documentos.","imagen_6.webp",1),
("ofertas impresoras","Impresora a color multifunción Epson EcoTank L3210 negra 220V", 379080,"Epson busca que sus clientes obtengan el máximo provecho de sus productos. Por ello, brinda soluciones de impresión con una amplia gama de dispositivos que cubren todos los usos y necesidades, tanto en casa como en el trabajo. Eficiencia y calidad. Imprimí archivos, escaneá documentos y hacé todas las fotocopias que necesités con esta impresora multifunción Epson, siempre lista para facilitar tu rutina de trabajo o estudio.","imagen_7.webp",1),
("ofertas tablets","Tablet Philco Tp10a332 10.1'' Ips 32gb 2gb Android 11", 76074,"¡Experimentá el futuro de la tecnología en tus manos con la increíble Tablet Philco! Disfrutá de tus películas, juegos y contenido favorito en una vibrante pantalla de 10 pulgadas con colores nítidos y realistas. Equipada con un procesador de alto rendimiento y amplia memoria RAM, te garantiza un rendimiento fluido y multitarea sin esfuerzo. Con una amplia capacidad de almacenamiento interno y soporte para tarjetas microSD, tendrás espacio más que suficiente para guardar tus archivos, fotos y videos. ","imagen_8.webp",1),
("ofertas tablets","Tablet Galaxy Tab A8 Wifi 10.5'' 64gb - Pantalla Inmersiva Color Silver", 204989,"La Tablet Galaxy Tab A8 Wifi 10.5'' 64gb - Pantalla Inmersiva Color Silver cuenta con una pantalla de 10,5' de ancho y un marco simétrico de solo 10,2 mm, ideal para sumergirte en tus contenidos favoritos.","imagen_9.webp",1),
("ofertas tablets","Tablet Galaxy Tab A8 Wifi 10.5'' 64gb - Pantalla Inmersiva Color Gray", 204989,"La Tablet Galaxy Tab A8 Wifi 10.5'' 64gb - Pantalla Inmersiva Color Gray es un dispositivo que te permitirá sumergirte en tus contenidos favoritos gracias a su pantalla de 10,5' de ancho con un marco simétrico de solo 10,2 mm. Su diseño combina un toque juvenil y fresco con la elegancia de su cuerpo metálico y un perfil ultrafino de tan solo 6,9 mm, características propias de las tablets Samsung.","imagen_10.webp",1);


select * from credenciales;
select * from productos;
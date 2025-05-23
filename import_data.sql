-- Eliminar tablas si existen
DROP TABLE IF EXISTS interacciones_usuario;
DROP TABLE IF EXISTS valoraciones;
DROP TABLE IF EXISTS reservas;
DROP TABLE IF EXISTS imagenes_hoteles;
DROP TABLE IF EXISTS hoteles;
DROP TABLE IF EXISTS usuario;

-- TABLA DE USUARIOS
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    edad INT NOT NULL,
    genero ENUM('F', 'M', 'Otro') NOT NULL,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLA DE HOTELES
CREATE TABLE hoteles (
    id_hotel INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(200) NOT NULL,
    descripcion TEXT,
    ubicacion VARCHAR(200),
    categoria VARCHAR(50),
    precio_promedio DECIMAL(10,2),
    imagen_url VARCHAR(500),
    fecha_creacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- TABLA DE IMÁGENES DE HOTELES (VARIAS IMÁGENES POR HOTEL)
CREATE TABLE imagenes_hoteles (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_hotel INT,
    url_imagen VARCHAR(500),
    FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel)
);

-- TABLA DE RESERVAS
CREATE TABLE reservas (
    id_reservas INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_hotel INT,
    fecha_entrada DATE,
    fecha_salida DATE,
    total_pago DECIMAL(10, 2),
    estado VARCHAR(50) DEFAULT 'pendiente',
    fecha_reserva DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario),
    FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel)
);

-- TABLA DE VALORACIONES
CREATE TABLE valoraciones (
    id_valoracion INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_hotel INT,
    puntuacion INT CHECK (puntuacion BETWEEN 1 AND 5),
    comentario TEXT,
    fecha_valoracion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario), -- Corregido: REFERENCES usuario(id_usuario)
    FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel)
);

-- TABLA DE INTERACCIONES (ALIMENTA EL SISTEMA RECOMENDADOR)
CREATE TABLE interacciones_usuario (
    id INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT,
    id_hotel INT,
    accion VARCHAR(50),  -- vista, clic, reserva, calificacion
    valor FLOAT DEFAULT 1.0,
    fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario), -- Corregido: REFERENCES usuario(id_usuario)
    FOREIGN KEY (id_hotel) REFERENCES hoteles(id_hotel)
);

-- Inserción de hoteles en la tabla 'hoteles'
INSERT INTO hoteles (nombre, descripcion, ubicacion, imagen_url, precio_promedio, categoria) VALUES
('Sofitel Legend Santa Clara Cartagena', 'Hotel de lujo ubicado en un convento restaurado del siglo XVII.', 'Centro Histórico, Cartagena', 'https://www.sofitel-legend-santa-clara.com/images/hotel.jpg', 950000, '5 estrellas'),
('Hyatt Regency Cartagena', 'Moderno hotel con vistas al mar Caribe y piscina infinita.', 'Bocagrande, Cartagena', 'https://www.hyatt.com/hyatt-regency-cartagena/images/hotel.jpg', 850000, '5 estrellas'),
('Hotel Caribe by Faranda Grand', 'Hotel histórico frente al mar con amplios jardines tropicales.', 'Bocagrande, Cartagena', 'https://www.hotelcaribe.com.co/images/hotel.jpg', 700000, '5 estrellas'),
('Hotel Estelar Cartagena de Indias', 'Hotel contemporáneo con centro de convenciones y spa.', 'Bocagrande, Cartagena', 'https://www.estelar.com.co/estelar-cartagena/images/hotel.jpg', 800000, '5 estrellas'),
('Hotel Charleston Santa Teresa Cartagena', 'Elegante hotel boutique en un edificio colonial restaurado.', 'Centro Histórico, Cartagena', 'https://www.charlestonsantateresa.com/images/hotel.jpg', 900000, '5 estrellas'),
('Hotel Las Américas Casa de Playa', 'Resort familiar con acceso directo a la playa y múltiples piscinas.', 'La Boquilla, Cartagena', 'https://www.hotellasamericas.com.co/casa-de-playa/images/hotel.jpg', 750000, '5 estrellas'),
('Hotel Las Américas Torre del Mar', 'Hotel moderno con vistas panorámicas y spa de lujo.', 'La Boquilla, Cartagena', 'https://www.hotellasamericas.com.co/torre-del-mar/images/hotel.jpg', 800000, '5 estrellas'),
('Hotel Capilla del Mar', 'Hotel frente al mar con restaurante gourmet y piscina.', 'Bocagrande, Cartagena', 'https://www.hotelcapilladelmar.com/images/hotel.jpg', 650000, '4 estrellas'),
('Hotel Almirante Cartagena', 'Hotel con centro de negocios y acceso directo a la playa.', 'Bocagrande, Cartagena', 'https://www.hotelalmirantecartagena.com.co/images/hotel.jpg', 700000, '5 estrellas'),
('Hotel InterContinental Cartagena', 'Hotel de lujo con vistas al mar y centro de convenciones.', 'Bocagrande, Cartagena', 'https://www.ihg.com/intercontinental/cartagena/images/hotel.jpg', 850000, '5 estrellas'),
('Hotel Dann Cartagena', 'Hotel con piscina frente al mar y habitaciones modernas.', 'Bocagrande, Cartagena', 'https://www.hoteldanncartagena.com/images/hotel.jpg', 600000, '4 estrellas'),
('Hotel Regatta Cartagena', 'Hotel con estilo náutico y vistas al mar Caribe.', 'Bocagrande, Cartagena', 'https://www.hotelregattacartagena.com/images/hotel.jpg', 550000, '4 estrellas'),
('Hotel Cartagena Plaza', 'Hotel con discoteca y piscina en la azotea.', 'Bocagrande, Cartagena', 'https://www.hotelcartagenaplaza.com/images/hotel.jpg', 500000, '4 estrellas'),
('Hotel Dorado Plaza Bocagrande', 'Hotel todo incluido con entretenimiento en vivo.', 'Bocagrande, Cartagena', 'https://www.doradoplaza.com.co/images/hotel.jpg', 480000, '4 estrellas'),
('Hotel Barlovento', 'Hotel boutique con diseño contemporáneo y restaurante.', 'Bocagrande, Cartagena', 'https://www.hotelbarlovento.com.co/images/hotel.jpg', 450000, '4 estrellas'),
('Hotel Bocagrande By GEH Suites', 'Hotel moderno con gimnasio y centro de negocios.', 'Bocagrande, Cartagena', 'https://www.gehsuites.com/bocagrande/images/hotel.jpg', 420000, '3 estrellas'),
('Hotel Stil Cartagena', 'Hotel económico en el centro con desayuno incluido.', 'Centro, Cartagena', 'https://www.hotelstilcartagena.com/images/hotel.jpg', 300000, '3 estrellas'),
('Hotel Don Pedro De Heredia', 'Hotel colonial con patio interior y decoración tradicional.', 'Centro Histórico, Cartagena', 'https://www.hoteldonpedrodeheredia.com/images/hotel.jpg', 350000, '3 estrellas'),
('Hotel Casa India Catalina', 'Hotel boutique en una casa colonial restaurada.', 'Centro Histórico, Cartagena', 'https://www.hotelindiacatalina.com/images/hotel.jpg', 400000, '3 estrellas'),
('Hotel Casa Gloria Boutique', 'Hotel con piscina y terraza en el centro histórico.', 'Centro Histórico, Cartagena', 'https://www.hotelcasagloria.com/images/hotel.jpg', 380000, '3 estrellas'),
('Hotel Boutique Callecitas de San Diego', 'Hotel con encanto en el barrio de San Diego.', 'San Diego, Cartagena', 'https://www.callecitasdesandiego.com/images/hotel.jpg', 360000, '3 estrellas'),
('Hotel Casa La Fe', 'Hotel boutique con terraza y desayuno gourmet.', 'Centro Histórico, Cartagena', 'https://www.hotelcasalafe.com/images/hotel.jpg', 390000, '3 estrellas'),
('Hotel Boutique La Artillería', 'Hotel con decoración artística y ambiente acogedor.', 'Getsemaní, Cartagena', 'https://www.laartilleriahotel.com/images/hotel.jpg', 370000, '3 estrellas'),
('Hotel Casa del Curato', 'Hotel en casa colonial con piscina y jardín.', 'Centro Histórico, Cartagena', 'https://www.hotelcasadelcurato.com/images/hotel.jpg', 340000, '3 estrellas'),
('Hotel Casa San Agustín', 'Hotel de lujo en una casa colonial con piscina.', 'Centro Histórico, Cartagena', 'https://www.hotelcasasanagustin.com/images/hotel.jpg', 950000, '5 estrellas'),
('Hotel Quadrifolio', 'Hotel boutique de lujo con servicio personalizado.', 'Centro Histórico, Cartagena', 'https://www.hotelquadrifolio.com/images/hotel.jpg', 900000, '5 estrellas'),
('Hotel Casa Pestagua', 'Hotel en mansión colonial con spa y restaurante gourmet.', 'Centro Histórico, Cartagena', 'https://www.hotelcasapestagua.com/images/hotel.jpg', 920000, '5 estrellas'),
('Hotel Boutique Casa del Coliseo', 'Hotel con diseño elegante y piscina en la azotea.', 'Centro Histórico, Cartagena', 'https://www.hotelcasadelcoliseo.com/images/hotel.jpg', 880000, '5 estrellas'),
('Hotel Boutique Casa Córdoba Estrella', 'Hotel con encanto y decoración tradicional.', 'Centro Histórico, Cartagena', 'https://www.casacordobaestrella.com/images/hotel.jpg', 850000, '5 estrellas'),
('Hotel Boutique Casa del Arzobispado', 'Hotel en casa colonial con piscina y jardín.', 'Centro Histórico, Cartagena', 'https://www.hotelarzobispado.com/images/hotel.jpg', 870000, '5 estrellas'),
('Hotel Boutique Casa Claver', 'Hotel con apartamentos de lujo y piscina.', 'Centro Histórico, Cartagena', 'https://www.casaclaver.com/images/hotel.jpg', 890000, '5 estrellas'),
('Hotel Boutique Casa La Merced', 'Hotel con ambiente romántico y decoración clásica.', 'Centro Histórico, Cartagena', 'https://www.casalamerced.com/images/hotel.jpg', 860000, '5 estrellas'),
('Hotel Boutique Casa del Curato', 'Hotel con piscina y ambiente acogedor.', 'Centro Histórico, Cartagena', 'https://www.hotelcasadelcurato.com/images/hotel.jpg', 840000, '5 estrellas'),
('Hotel Boutique Casa del Coliseo', 'Hotel con diseño elegante y piscina en la azotea.', 'Centro Histórico, Cartagena', 'https://www.hotelcasadelcoliseo.com/images/hotel.jpg', 880000, '5 estrellas'),
('Hotel Boutique Casa San Agustín', 'Hotel de lujo en una casa colonial con piscina.', 'Centro Histórico, Cartagena', 'https://www.hotelcasasanagustin.com/images/hotel.jpg', 950000, '5 estrellas'),
('Hotel Boutique Casa Pestagua', 'Hotel en mansión colonial con spa y restaurante gourmet.', 'Centro Histórico, Cartagena', 'https://www.hotelcasapestagua.com/images/hotel.jpg', 920000, '5 estrellas'),
('Hotel Las Américas Casa de Playa', 'Resort frente al mar con múltiples piscinas y restaurantes.', 'La Boquilla, Cartagena', 'https://www.hotellasamericas.com.co/images/casa-de-playa.jpg', 750000, '5 estrellas'),
('Hilton Cartagena Hotel', 'Hotel de lujo con acceso directo a la playa y centro de convenciones.', 'El Laguito, Cartagena', 'https://www.hilton.com/images/hilton-cartagena.jpg', 900000, '5 estrellas'),
('Hotel Capilla del Mar', 'Hotel moderno con vista al mar y servicios de spa.', 'Bocagrande, Cartagena', 'https://www.capilladelmar.com/images/hotel.jpg', 680000, '4 estrellas'),
('Hotel Caribe by Faranda Grand', 'Hotel histórico con amplios jardines y acceso a la playa.', 'Bocagrande, Cartagena', 'https://www.hotelcaribe.com.co/images/hotel.jpg', 700000, '5 estrellas'),
('Hotel Charleston Santa Teresa Cartagena', 'Elegante hotel boutique en un convento restaurado del siglo XVII.', 'Centro Histórico, Cartagena', 'https://www.charlestonsantateresa.com/images/hotel.jpg', 950000, '5 estrellas'),
('Hotel Estelar Cartagena de Indias', 'Hotel contemporáneo con centro de convenciones y spa.', 'Bocagrande, Cartagena', 'https://www.estelar.com.co/estelar-cartagena/images/hotel.jpg', 800000, '5 estrellas'),
('Hotel Boutique Casa del Coliseo', 'Hotel boutique en una casa colonial restaurada con piscina en la azotea.', 'Centro Histórico, Cartagena', 'https://www.casadelcoliseo.com/images/hotel.jpg', 850000, '4 estrellas'),
('Hotel Quadrifolio', 'Hotel boutique de lujo con arquitectura colonial y servicio personalizado.', 'Centro Histórico, Cartagena', 'https://www.hotelquadrifolio.com/images/hotel.jpg', 920000, '5 estrellas'),
('Hotel Bantu by Faranda Boutique', 'Hotel con encanto colonial y piscina en la azotea.', 'Centro Histórico, Cartagena', 'https://www.hotelbantu.com/images/hotel.jpg', 780000, '4 estrellas'),
('Hotel Casa San Agustin', 'Hotel boutique de lujo con diseño colonial y servicios exclusivos.', 'Centro Histórico, Cartagena', 'https://www.hotelcasasanagustin.com/images/hotel.jpg', 970000, '5 estrellas'),
('Hotel Plaza Real', 'Hotel económico en el barrio Manga.', 'Manga, Cartagena', 'https://www.hotelplazareal.com/images/hotel.jpg', 250000, '2 estrellas'),
('Hotel Casa Cartagena', 'Hotel boutique con terraza y bar.', 'Centro Histórico, Cartagena', 'https://www.hotelcasacartagena.com/images/hotel.jpg', 420000, '3 estrellas'),
('Hotel Brisas del Caribe', 'Hotel familiar con acceso directo a la playa.', 'Bocagrande, Cartagena', 'https://www.hotelbrisasdelcaribe.com/images/hotel.jpg', 500000, '4 estrellas'),
('Hotel Sunset View', 'Hotel moderno con vistas espectaculares al atardecer.', 'La Boquilla, Cartagena', 'https://www.hotelsunsetview.com/images/hotel.jpg', 550000, '4 estrellas'),
('Hotel Palma Real', 'Hotel con jardines tropicales y piscina al aire libre.', 'Bocagrande, Cartagena', 'https://www.hotelpalmareal.com/images/hotel.jpg', 480000, '4 estrellas'),
('Hotel Ocean Blue', 'Hotel con acceso privado a la playa y bar en la azotea.', 'Bocagrande, Cartagena', 'https://www.hoteloceanblue.com/images/hotel.jpg', 620000, '4 estrellas'),
('Hotel Casa Cartagena Premium', 'Hotel exclusivo con vista al centro histórico.', 'Centro Histórico, Cartagena', 'https://www.hotelcasacartagenapremium.com/images/hotel.jpg', 650000, '4 estrellas'),
('Hotel Blue Moon', 'Hotel moderno con diseño minimalista y piscina.', 'Bocagrande, Cartagena', 'https://www.hotelbluemoon.com/images/hotel.jpg', 520000, '4 estrellas'),
('Hotel Mirador del Mar', 'Hotel con terraza panorámica y vistas al mar.', 'La Boquilla, Cartagena', 'https://www.hotelmiradordelmar.com/images/hotel.jpg', 570000, '4 estrellas'),
('Hotel Sol Caribe', 'Hotel económico con ambiente familiar y restaurante local.', 'Crespo, Cartagena', 'https://www.hotelsolcaribe.com/images/hotel.jpg', 320000, '3 estrellas'),
('Hotel Sunshine', 'Hotel boutique con terraza y bar al aire libre.', 'San Diego, Cartagena', 'https://www.hotelsunshine.com/images/hotel.jpg', 430000, '3 estrellas'),
('Hotel Royal Palm', 'Hotel de lujo con spa y gimnasio moderno.', 'Centro Histórico, Cartagena', 'https://www.hotelroyalpalm.com/images/hotel.jpg', 940000, '5 estrellas'),
('Hotel Coral Bay', 'Hotel con acceso a playa privada y deportes acuáticos.', 'Bocagrande, Cartagena', 'https://www.hotelcoralbay.com/images/hotel.jpg', 680000, '4 estrellas'),
('Hotel Isla Bonita', 'Hotel temático con decoración caribeña y shows en vivo.', 'Bocagrande, Cartagena', 'https://www.hotelislabonita.com/images/hotel.jpg', 470000, '4 estrellas'),
('Hotel Crystal Palace', 'Hotel moderno con restaurante de cocina fusión.', 'Centro Histórico, Cartagena', 'https://www.hotelcrystalpalace.com/images/hotel.jpg', 720000, '4 estrellas'),
('Hotel Bamboo', 'Hotel ecológico con jardines tropicales y piscinas naturales.', 'Manga, Cartagena', 'https://www.hotelbamboo.com/images/hotel.jpg', 480000, '3 estrellas'),
('Hotel Mar Azul', 'Hotel frente al mar con piscina infinita y bar acuático.', 'La Boquilla, Cartagena', 'https://www.hotelmarazul.com/images/hotel.jpg', 600000, '4 estrellas'),
('Hotel Casa Bella Vista', 'Hotel boutique con vistas panorámicas y diseño moderno.', 'San Diego, Cartagena', 'https://www.hotelcasabellavista.com/images/hotel.jpg', 550000, '4 estrellas'),
('Hotel Ocean Pearl', 'Hotel frente al mar con bar en la azotea y área de juegos.', 'Bocagrande, Cartagena', 'https://www.hoteloceanpearl.com/images/hotel.jpg', 650000, '4 estrellas'),
('Hotel Sol Caribe Deluxe', 'Hotel económico con piscina y restaurante típico.', 'Crespo, Cartagena', 'https://www.hotelsolcaribedeluxe.com/images/hotel.jpg', 350000, '3 estrellas'),
('Hotel Sunset Paradise', 'Hotel con terraza con vista al atardecer y spa.', 'Centro Histórico, Cartagena', 'https://www.hotelsunsetparadise.com/images/hotel.jpg', 720000, '4 estrellas'),
('Hotel Terra Nova', 'Hotel ecológico con jardines y actividades al aire libre.', 'Manga, Cartagena', 'https://www.hotelterranova.com/images/hotel.jpg', 490000, '3 estrellas'),
('Hotel Coral Reef', 'Hotel con acceso directo a playa privada y bar en la piscina.', 'La Boquilla, Cartagena', 'https://www.hotelcoralreef.com/images/hotel.jpg', 630000, '4 estrellas'),
('Hotel Luna Azul', 'Hotel temático con diseño caribeño y espectáculos en vivo.', 'Bocagrande, Cartagena', 'https://www.hotellunaazul.com/images/hotel.jpg', 470000, '4 estrellas'),
('Hotel Emerald Palace', 'Hotel de lujo con spa, gimnasio y restaurante gourmet.', 'Centro Histórico, Cartagena', 'https://www.hotelemeraldpalace.com/images/hotel.jpg', 950000, '5 estrellas'),
('Hotel Brisa Marina', 'Hotel con piscina infinita y suites con vista al mar.', 'La Boquilla, Cartagena', 'https://www.hotelbrisamarina.com/images/hotel.jpg', 690000, '4 estrellas'),
('Hotel Vista Real', 'Hotel con habitaciones modernas y bar con vista a la ciudad.', 'Centro, Cartagena', 'https://www.hotelvistareal.com/images/hotel.jpg', 520000, '4 estrellas'),
('Hotel Esplendor', 'Hotel boutique con diseño minimalista y restaurante internacional.', 'San Diego, Cartagena', 'https://www.hotelesplendor.com/images/hotel.jpg', 580000, '4 estrellas'),
('Hotel Casa Linda', 'Hotel colonial con patio interior y ambiente acogedor.', 'Centro Histórico, Cartagena', 'https://www.hotelcasalinda.com/images/hotel.jpg', 370000, '3 estrellas'),
('Hotel Luna Mar', 'Hotel frente al mar con piscina y actividades acuáticas.', 'Bocagrande, Cartagena', 'https://www.hotellunamar.com/images/hotel.jpg', 610000, '4 estrellas'),
('Hotel Paraiso Caribe', 'Hotel económico con restaurante y bar en la azotea.', 'Getsemaní, Cartagena', 'https://www.hotelparaisocaribe.com/images/hotel.jpg', 330000, '3 estrellas'),
('Hotel Casa del Mar', 'Hotel boutique con ambiente rústico y terraza con vista al mar.', 'La Boquilla, Cartagena', 'https://www.hotelcasadelmar.com/images/hotel.jpg', 520000, '4 estrellas'),
('Hotel Isla Bonita', 'Hotel exclusivo en una pequeña isla privada con acceso en lancha.', 'Islas del Rosario, Cartagena', 'https://www.hotelislabonita.com/images/hotel.jpg', 850000, '5 estrellas'),
('Hotel Santa María Colonial', 'Hotel boutique con decoración colonial y desayuno incluido.', 'Centro Histórico, Cartagena', 'https://www.hotelsantamariacolonial.com/images/hotel.jpg', 450000, '3 estrellas'),
('Hotel Sunset Bay', 'Hotel con terraza para ver el atardecer y bar en la azotea.', 'Bocagrande, Cartagena', 'https://www.hotelsunsetbay.com/images/hotel.jpg', 600000, '4 estrellas'),
('Hotel Casa Blanca', 'Hotel boutique en una casa colonial con patio central y piscina.', 'San Diego, Cartagena', 'https://www.hotelcasablanca.com/images/hotel.jpg', 480000, '3 estrellas'),
('Hotel Mirador del Mar', 'Hotel con habitaciones con vista al mar y restaurante gourmet.', 'La Boquilla, Cartagena', 'https://www.hotelmiradordelmar.com/images/hotel.jpg', 720000, '4 estrellas'),
('Hotel Pacifico', 'Hotel económico con habitaciones confortables y bar en el lobby.', 'Crespo, Cartagena', 'https://www.hotelpacifico.com/images/hotel.jpg', 310000, '3 estrellas'),
('Hotel Sol Caribe Beach', 'Hotel familiar frente al mar con actividades para niños.', 'Bocagrande, Cartagena', 'https://www.hotelsolcaribebeach.com/images/hotel.jpg', 590000, '4 estrellas'),
('Hotel Oasis Urbano', 'Hotel contemporáneo con piscina en la azotea y restaurante fusión.', 'Centro, Cartagena', 'https://www.hoteloasisurbano.com/images/hotel.jpg', 680000, '4 estrellas'),
('Hotel Coral Dreams', 'Hotel temático inspirado en el mundo marino con piscina interior.', 'Bocagrande, Cartagena', 'https://www.hotelcoraldreams.com/images/hotel.jpg', 550000, '4 estrellas'),
('Hotel Tropical Inn', 'Hotel boutique con jardines tropicales y restaurante caribeño.', 'Getsemaní, Cartagena', 'https://www.hoteltropicalinn.com/images/hotel.jpg', 470000, '3 estrellas'),
('Hotel Casa de la Roca', 'Hotel con diseño moderno y terraza con piscina.', 'San Diego, Cartagena', 'https://www.hotelcasadelaroca.com/images/hotel.jpg', 610000, '4 estrellas'),
('Hotel Mar Azul', 'Hotel económico con desayuno incluido y habitaciones sencillas.', 'Centro, Cartagena', 'https://www.hotelmarazul.com/images/hotel.jpg', 350000, '3 estrellas'),
('Hotel Colonial Plaza', 'Hotel con ambiente colonial y patio con fuente de agua.', 'Centro Histórico, Cartagena', 'https://www.hotelcolonialplaza.com/images/hotel.jpg', 440000, '3 estrellas'),
('Hotel Playa Blanca Suites', 'Hotel frente al mar con suites familiares y actividades acuáticas.', 'Playa Blanca, Cartagena', 'https://www.hotelplayablancasuites.com/images/hotel.jpg', 750000, '5 estrellas'),
('Hotel Marina del Sol', 'Hotel con vista a la bahía y restaurante con cocina internacional.', 'Bocagrande, Cartagena', 'https://www.hotelmarinadelsol.com/images/hotel.jpg', 690000, '4 estrellas'),
('Hotel Luna Nueva', 'Hotel boutique con habitaciones temáticas y ambiente romántico.', 'Getsemaní, Cartagena', 'https://www.hotellunanueva.com/images/hotel.jpg', 530000, '3 estrellas'),
('Hotel Flamingo Beach', 'Hotel familiar con parque acuático y restaurante buffet.', 'La Boquilla, Cartagena', 'https://www.hotelflamingobeach.com/images/hotel.jpg', 580000, '4 estrellas'),
('Hotel Ocean View', 'Hotel moderno con terraza panorámica y bar en la azotea.', 'Centro Histórico, Cartagena', 'https://www.hoteloceanview.com/images/hotel.jpg', 820000, '5 estrellas'),
('Hotel Casa del Sol', 'Hotel con jardín interior y decoración colonial.', 'San Diego, Cartagena', 'https://www.hotelcasadelsol.com/images/hotel.jpg', 490000, '3 estrellas'),
('Hotel Riviera Caribe', 'Hotel frente al mar con piscina infinita y gimnasio.', 'Bocagrande, Cartagena', 'https://www.hotelrivieracaribe.com/images/hotel.jpg', 720000, '4 estrellas'),
('Hotel Laguna Azul', 'Hotel económico con desayuno incluido y habitaciones básicas.', 'Crespo, Cartagena', 'https://www.hotellagunaazul.com/images/hotel.jpg', 320000, '3 estrellas'),
('Hotel Miramar Suites', 'Hotel con habitaciones amplias y vista al océano.', 'Centro, Cartagena', 'https://www.hotelmiramarsuites.com/images/hotel.jpg', 670000, '4 estrellas'),
('Hotel Terraza del Caribe', 'Hotel boutique con terraza y café-bar.', 'Getsemaní, Cartagena', 'https://www.hotelterrazadelcaribe.com/images/hotel.jpg', 540000, '3 estrellas'),
('Hotel Royal Sunset', 'Hotel con suites de lujo y piscina en la azotea.', 'Bocagrande, Cartagena', 'https://www.hotelroyalsunset.com/images/hotel.jpg', 880000, '5 estrellas'),
('Hotel Casa Marina', 'Hotel rústico con ambiente acogedor y jardín tropical.', 'San Diego, Cartagena', 'https://www.hotelcasamarina.com/images/hotel.jpg', 460000, '3 estrellas'),
('Hotel Esmeralda Beach', 'Hotel frente a la playa con restaurante y spa.', 'La Boquilla, Cartagena', 'https://www.hotelesmeraldabeach.com/images/hotel.jpg', 720000, '4 estrellas'),
('Hotel Coral Reef', 'Hotel moderno con habitaciones temáticas y piscina climatizada.', 'Centro Histórico, Cartagena', 'https://www.hotelcoralreef.com/images/hotel.jpg', 630000, '4 estrellas'),
('Hotel Casa Verde', 'Hotel ecológico con jardines y habitaciones sostenibles.', 'Getsemaní, Cartagena', 'https://www.hotelcasaverde.com/images/hotel.jpg', 570000, '3 estrellas');

-- Inserciones de ejemplo para la tabla 'usuario' (si no tienes usuarios aún)
INSERT INTO usuario (nombre, email, password, edad, genero) VALUES
('Usuario Ejemplo 1', 'usuario1@example.com', 'pass1', 30, 'F'),
('Usuario Ejemplo 2', 'usuario2@example.com', 'pass2', 25, 'M'),
('Usuario Ejemplo 3', 'usuario3@example.com', 'pass3', 28, 'M');

-- Inserciones de ejemplo para la tabla 'valoraciones'
-- Asegúrate de que los id_usuario y id_hotel a continuación existan en sus respectivas tablas
INSERT INTO valoraciones (id_usuario, id_hotel, puntuacion, comentario) VALUES
(1, 1, 5, '¡Increíble experiencia en este hotel de lujo!'),
(1, 5, 4, 'Hotel con mucho encanto colonial, bien ubicado.'),
(2, 2, 4, 'Vistas espectaculares y piscina infinita.'),
(2, 8, 3, 'Un hotel correcto, buena ubicación frente al mar.'),
(3, 1, 5, 'Simplemente perfecto.'),
(3, 15, 4, 'Muy buen servicio y diseño moderno.'),
(1, 10, 5, 'Lujo y comodidad en un solo lugar.');

SELECT * FROM usuario WHERE id_usuario IN (1, 2, 3);
SELECT * FROM hoteles WHERE id_hotel IN (1, 5, 2, 8, 15, 10); -- O los IDs de hotel específicos en tus INSERTs de valoraciones 

SELECT COUNT(*) FROM valoraciones; 
-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 08-07-2020 a las 16:35:10
-- Versión del servidor: 10.4.11-MariaDB
-- Versión de PHP: 7.4.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `library_db`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `generate_due_list` ()  NO SQL
SELECT I.issue_id, M.email, B.isbn, B.title
FROM book_issue_log I INNER JOIN member M on I.member = M.username INNER JOIN book B ON I.book_isbn = B.isbn
WHERE DATEDIFF(CURRENT_DATE, I.due_date) >= 0 AND DATEDIFF(CURRENT_DATE, I.due_date) % 5 = 0 AND (I.last_reminded IS NULL OR DATEDIFF(I.last_reminded, CURRENT_DATE) <> 0)$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `book`
--

CREATE TABLE `book` (
  `isbn` char(13) NOT NULL,
  `title` varchar(80) NOT NULL,
  `author` varchar(80) NOT NULL,
  `category` varchar(80) NOT NULL,
  `price` int(4) UNSIGNED NOT NULL,
  `copies` int(10) UNSIGNED NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `book`
--

INSERT INTO `book` (`isbn`, `title`, `author`, `category`, `price`, `copies`) VALUES
('0000545010225', 'Harry Potter y las Reliquias de la Muerte', 'J. K. Rowling', 'Ficción', 55000, 451),
('0000553103547', 'Juego de Tronos', 'George R. R. Martin', 'Ficción', 50000, 13),
('0000553106635', 'Una tormenta de espadas', 'George R. R. Martin', 'Ficción', 55000, 15),
('0000553108034', 'Choque de Reyes', 'George R. R. Martin', 'Ficción', 50000, 10),
('0000553801503', 'Un festín para los cuervos', 'George R. R. Martin', 'Ficción', 60000, 20),
('0000747532699', 'Harry Potter y la Piedra Filosofal', 'J. K. Rowling', 'Ficción', 30000, 12),
('0000747538492', 'Harry Potter y la cámara de los secretos', 'J. K. Rowling', 'Ficción', 30000, 10),
('0000747542155', 'Harry Potter y el prisionero de Azkaban', 'J. K. Rowling', 'Ficción', 35000, 16),
('0000747546240', 'Harry Potter y el cáliz de fuego', 'J. K. Rowling', 'Ficción', 40000, 15),
('0000747551006', 'Harry Potter y la Orden del Fénix', 'J. K. Rowling', 'Ficción', 40000, 20),
('0000747581088', 'Harry Potter y el Príncipe Mestizo', 'J. K. Rowling', 'Ficción', 50000, 25),
('9780066620992', 'Bueno a genial', 'Jim Collins', 'No ficción', 30000, 10),
('9780241257555', 'El túnel de las palomas', 'John le CarrÃ©', 'No ficción', 20000, 25),
('9780439023511', 'Mockingjay', 'Suzanne Collins', 'Fiction', 50000, 20),
('9780439023528', 'Los juegos del hambre', 'Suzanne Collins', 'Ficción', 40000, 10),
('9780545227247', 'En llamas', 'Suzanne Collins', 'Ficción', 40000, 15),
('9780553801477', 'Una danza con Dragones', 'George R. R. Martin', 'Ficción', 60000, 30),
('9780590353427', 'Comienzo del desarrollo de aplicaciones de Android', 'Wei Meng Lee', 'Educación', 15600, 45),
('9780967752808', 'Sandbox Wisdom', 'Tom Asacker', 'No ficción', 25000, 5),
('9781501141515', 'Nacido para correr', 'Bruce Springsteen', 'No ficción', 25000, 20),
('9788183331630', 'Empezemos con C', 'Jorge Vega', 'Educación', 20000, 22),
('9789350776667', 'Gráficos por computadora y realidad virtual', 'Julián Páez', 'Educación', 10000, 30),
('9789350776773', 'Microcontrolador y Sistemas Embebidos', 'Natalia Pérez', 'Educación', 80000, 15),
('9789350777077', 'Sistemas avanzados de gestión de bases de datos', 'Daniel Camargo', 'Educación', 60000, 30),
('9789350777121', 'Sistemas operativos', 'Roberto García', 'Educación', 50000, 24),
('9789351194545', 'Tecnologías de código abierto', 'Juan Castro', 'Educación', 10000, 20),
('9789381626719', 'Quédense hambrientos quédense tontos', 'Andrés Mendoza', 'No ficción', 10000, 5);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `book_issue_log`
--

CREATE TABLE `book_issue_log` (
  `issue_id` int(11) NOT NULL,
  `member` varchar(20) NOT NULL,
  `book_isbn` varchar(13) NOT NULL,
  `due_date` date NOT NULL,
  `last_reminded` date DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Disparadores `book_issue_log`
--
DELIMITER $$
CREATE TRIGGER `issue_book` BEFORE INSERT ON `book_issue_log` FOR EACH ROW BEGIN
	SET NEW.due_date = DATE_ADD(CURRENT_DATE, INTERVAL 7 DAY);
    UPDATE member SET balance = balance - (SELECT price FROM book WHERE isbn = NEW.book_isbn) WHERE username = NEW.member;
    UPDATE book SET copies = copies - 1 WHERE isbn = NEW.book_isbn;
    DELETE FROM pending_book_requests WHERE member = NEW.member AND book_isbn = NEW.book_isbn;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `return_book` BEFORE DELETE ON `book_issue_log` FOR EACH ROW BEGIN
    UPDATE member SET balance = balance + (SELECT price FROM book WHERE isbn = OLD.book_isbn) WHERE username = OLD.member;
    UPDATE book SET copies = copies + 1 WHERE isbn = OLD.book_isbn;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `librarian`
--

CREATE TABLE `librarian` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` char(40) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `librarian`
--

INSERT INTO `librarian` (`id`, `username`, `password`) VALUES
(1, 'configuroweb', 'AD4BEDC9F4F98E0513315BCFD543E4F8E2C00A77');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `member`
--

CREATE TABLE `member` (
  `id` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` char(40) NOT NULL,
  `name` varchar(80) NOT NULL,
  `email` varchar(80) NOT NULL,
  `balance` int(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Volcado de datos para la tabla `member`
--

INSERT INTO `member` (`id`, `username`, `password`, `name`, `email`, `balance`) VALUES
(8, 'mauron', 'ad4bedc9f4f98e0513315bcfd543e4f8e2c00a77', 'Mauricio Sevilla', 'configuroweb@gmail.com', 80529);

--
-- Disparadores `member`
--
DELIMITER $$
CREATE TRIGGER `add_member` AFTER INSERT ON `member` FOR EACH ROW DELETE FROM pending_registrations WHERE username = NEW.username
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `remove_member` AFTER DELETE ON `member` FOR EACH ROW DELETE FROM pending_book_requests WHERE member = OLD.username
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pending_book_requests`
--

CREATE TABLE `pending_book_requests` (
  `request_id` int(11) NOT NULL,
  `member` varchar(20) NOT NULL,
  `book_isbn` varchar(13) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pending_registrations`
--

CREATE TABLE `pending_registrations` (
  `username` varchar(20) NOT NULL,
  `password` char(40) NOT NULL,
  `name` varchar(80) NOT NULL,
  `email` varchar(80) NOT NULL,
  `balance` int(4) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `book`
--
ALTER TABLE `book`
  ADD PRIMARY KEY (`isbn`);

--
-- Indices de la tabla `book_issue_log`
--
ALTER TABLE `book_issue_log`
  ADD PRIMARY KEY (`issue_id`);

--
-- Indices de la tabla `librarian`
--
ALTER TABLE `librarian`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`);

--
-- Indices de la tabla `member`
--
ALTER TABLE `member`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `username` (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indices de la tabla `pending_book_requests`
--
ALTER TABLE `pending_book_requests`
  ADD PRIMARY KEY (`request_id`);

--
-- Indices de la tabla `pending_registrations`
--
ALTER TABLE `pending_registrations`
  ADD PRIMARY KEY (`username`),
  ADD UNIQUE KEY `email` (`email`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `book_issue_log`
--
ALTER TABLE `book_issue_log`
  MODIFY `issue_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT de la tabla `librarian`
--
ALTER TABLE `librarian`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `member`
--
ALTER TABLE `member`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `pending_book_requests`
--
ALTER TABLE `pending_book_requests`
  MODIFY `request_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
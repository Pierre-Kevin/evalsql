-- Vue

CREATE VIEW pro_catalogue
AS
SELECT * FROM products
JOIN categories ON categories.cat_id = products.pro_cat_id

-- Procedure Stockée

DELIMITER |

CREATE PROCEDURE facture(IN p_libelle VARCHAR(50),OUT p_montant_total INT)

BEGIN 

SELECT SUM(ode_unit_price * ode_quantity) INTO p_montant_total
FROM orders_details 
JOIN orders 
ON orders_details.ode_ord_id = orders.ord_id
WHERE ord_id = p_libelle;

END |
DELIMITER ;

-- appeler la procédure
CALL facture(3, @p_total);
SELECT @p_total AS 'prix total';

-- Trigger

DELIMITER |
CREATE TRIGGER after_products_update
AFTER UPDATE
ON products
FOR EACH ROW
BEGIN
   IF new.pro_stock < new.pro_stock_alert THEN 
   DELETE FROM commander_articles WHERE codart = new.pro_id; 
   INSERT INTO commander_articles (codart, date, qte) values(new.pro_id, now(), new.pro_stock_alert);
   END IF;
END |
DELIMITER ;

-- Transaction

START TRANSACTION;
INSERT INTO posts (pos_libelle)
VALUES ('Retraité');

SET @idshop = (select sho_id from shops where sho_city = 'Arras');
SET @idretraite = (select pos_id from posts where pos_libelle = 'Retraité');

UPDATE employees set emp_pos_id = @idretraite WHERE emp_lastname = 'HANNAH' AND  emp_firstname = 'Amity'AND emp_sho_id = @idshop;
SELECT pos_id FROM posts WHERE pos_libelle = 'Pépinieriste';
SELECT *
From Employees
JOIN posts ON emp_pos_id = posts.pos_id
WHERE pos_libelle = 'Pépiniériste' AND emp_sho_id = @idshop;

SET @id_new_manager = (SELECT emp_id
FROM employees 
JOIN posts ON emp_pos_id = posts.pos_id
WHERE pos_libelle = 'Pépiniériste' AND emp_sho_id = @idshop
ORDER BY emp_enter_date
LIMIT 1);

SET @post_id_manager = (SELECT pos_id
FROM posts 
WHERE pos_libelle LIKE 'Manager%'
limit 1);

UPDATE employees
SET 
emp_salary = (emp_salary*1.05),
emp_pos_id = @post_id_manager 
WHERE emp_id = @id_new_manager;

SET @les_pepinieristes = (SELECT pos_id
FROM posts
WHERE pos_libelle = 'Pépinieriste');

SET @id_new_manager = (SELECT emp_id 
FROM employees 
WHERE emp_firstname = 'Dorian');
UPDATE employees
SET 
emp_superior_id = @id_new_manager
WHERE emp_pos_id = @les_pepinieristes;

-- Inserer une ligne retraité dans la table POSTS
--Récuperer l'identifiant du magasin d'Arras ainsi que l'identifiant du poste RETRAITE
--Mettre a jour la situation de l'employée Amity HANNAH donc la basculer dans le poste RETRAITE
--Récuperer l'identifiant du poste pepinièriste
--Trouver le Pépinieriste du magasin d'Arras le plus ancien (avec date d'entrée en Entreprise "Emp_enter_date) en utilisant la fontion "MIN"
-- Récuperer son ID et modifier sa fiche Emp_Salary multipliant son salaire par 1.5
-- On fait un update sur tous les pépiniéristes pour leur attribuer le nouveau manager donc supérieur
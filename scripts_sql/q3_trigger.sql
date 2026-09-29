--codigo
CREATE TABLE IF NOT EXISTS tb_log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) NOT NULL,
    operacao VARCHAR(20) NOT NULL,
    tabela_afetada VARCHAR(50) NOT NULL,
    identificacao_problema TEXT NOT NULL
);

DELIMITER //

CREATE PROCEDURE sp_inserir_pagamento (
    IN p_customer_id INT,
    IN p_staff_id INT,
    IN p_rental_id INT,
    IN p_amount DECIMAL(5,2),
    IN p_payment_date DATETIME
)
BEGIN
    IF p_amount <= 0 THEN
        INSERT INTO tb_log_auditoria (usuario, operacao, tabela_afetada, identificacao_problema)
        VALUES (
            USER(), 
            'INSERT', 
            'payment', 
            CONCAT('Tentativa de inserção de pagamento inválido de R$ ', p_amount, ' para o cliente ID ', p_customer_id)
        );
        COMMIT;
        
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'VIOLAÇÃO DE REGRA DE NEGÓCIO: O valor do pagamento deve ser estritamente maior que R$ 0,00.';
    ELSE
        INSERT INTO payment (customer_id, staff_id, rental_id, amount, payment_date)
        VALUES (p_customer_id, p_staff_id, p_rental_id, p_amount, p_payment_date);
    END IF;
END//

DELIMITER ;



--teste
CALL sp_inserir_pagamento(1, 1, 1, 0.00, NOW());

SELECT * FROM tb_log_auditoria;

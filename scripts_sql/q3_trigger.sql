USE sakila;

CREATE TABLE IF NOT EXISTS tb_log_auditoria (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    data_hora DATETIME DEFAULT CURRENT_TIMESTAMP,
    usuario VARCHAR(100) NOT NULL,
    operacao VARCHAR(20) NOT NULL,
    tabela_afetada VARCHAR(50) NOT NULL,
    identificacao_problema TEXT NOT NULL
) ENGINE = MyISAM;


ALTER TABLE tb_log_auditoria ENGINE = MyISAM;


DELIMITER //

CREATE TRIGGER trg_valida_pagamento_bi
BEFORE INSERT ON payment
FOR EACH ROW
BEGIN
    IF NEW.amount <= 0 THEN
        INSERT INTO tb_log_auditoria (
            usuario,
            operacao,
            tabela_afetada,
            identificacao_problema
        )
        VALUES (
            USER(),
            'INSERT',
            'payment',
            CONCAT(
                'Tentativa de inserção de pagamento inválido de R$ ',
                NEW.amount,
                ' para o cliente ID ',
                NEW.customer_id
            )
        );
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'VIOLAÇÃO DE REGRA DE NEGÓCIO: O valor do pagamento deve ser estritamente maior que R$ 0,00.';
    END IF;
END//

DELIMITER ;


--teste

INSERT INTO payment ( 
customer_id,
 staff_id, 
 rental_id, 
 amount, 
 payment_date )
VALUES ( 1, 1, 1, 0.00, NOW() );


SELECT * FROM tb_log_auditoria;

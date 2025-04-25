-- Banco 
CREATE DATABASE red_dead_redemption2;
USE red_dead_redemption2;

-- Tabela: Personagens
CREATE TABLE personagens (
SELECT * FROM personagens;
SELECT * FROM armas;
SELECT * FROM missoes;
SELECT * FROM animais;
SELECT * FROM locais;

--Stored Procedures
--sp_missoes_por_personagem - Lista todas as missões de um personagem específico

DELIMITER //
CREATE PROCEDURE sp_missoes_por_personagem(IN personagem_id INT)
BEGIN
    SELECT m.titulo, m.descricao, m.recompensa, m.localizacao
    FROM missoes m
    WHERE m.id_personagem_responsavel = personagem_id;
END //
DELIMITER ; 
--sp_armas_por_tipo - Lista armas de um tipo específico com filtro de dano mínimo

DELIMITER //
CREATE PROCEDURE sp_armas_por_tipo(IN tipo_arma VARCHAR(50), IN dano_minimo INT)
BEGIN
    SELECT a.nome_arma, a.dano, a.alcance, p.nome AS dono
    FROM armas a
    JOIN personagens p ON a.id_personagem_dono = p.id_personagem
    WHERE a.tipo = tipo_arma AND a.dano >= dano_minimo;
END //
DELIMITER ; 

--sp_atualizar_status_personagem - Atualiza o status de um personagem

DELIMITER //
CREATE PROCEDURE sp_atualizar_status_personagem(IN personagem_id INT, IN novo_status VARCHAR(20))
BEGIN
    UPDATE personagens 
    SET status = novo_status 
    WHERE id_personagem = personagem_id;
END //
DELIMITER ;

--sp_animais_perigosos - Lista animais perigosos com possibilidade de filtro por tipo

DELIMITER //
CREATE PROCEDURE sp_animais_perigosos(IN tipo_animal VARCHAR(50))
BEGIN
    IF tipo_animal IS NULL THEN
        SELECT nome_comum, tipo, perigo
        FROM animais
        WHERE perigo IN ('alta', 'média')
        ORDER BY perigo DESC;
    ELSE
        SELECT nome_comum, tipo, perigo
        FROM animais
        WHERE perigo IN ('alta', 'média') AND tipo = tipo_animal
        ORDER BY perigo DESC;
    END IF;
END //
DELIMITER ;

-- Triggers --
-- Trigger 1: Impedir inserção de personagem com status inválido
DELIMITER //
CREATE TRIGGER trg_validar_status_personagem
BEFORE INSERT ON personagens
FOR EACH ROW
BEGIN
    IF NEW.status NOT IN ('vivo', 'morto', 'desaparecido', 'expulso') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Status inválido para personagem.';
    END IF;
END //
DELIMITER ;

-- Trigger 2: Atualizar status de personagem para 'morto' ao remover todas suas armas
DELIMITER //
CREATE TRIGGER trg_personagem_sem_armas
AFTER DELETE ON armas
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM armas WHERE id_personagem_dono = OLD.id_personagem_dono) THEN
        UPDATE personagens
        SET status = 'morto'
        WHERE id_personagem = OLD.id_personagem_dono;
    END IF;
END //
DELIMITER ;

-- Trigger 3: Impedir que animal perigoso seja domesticável
DELIMITER //
CREATE TRIGGER trg_animal_perigoso_domesticavel
BEFORE INSERT ON animais
FOR EACH ROW
BEGIN
    IF NEW.perigo IN ('alta', 'média') AND NEW.pode_domesticar = TRUE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Animais perigosos não podem ser domesticáveis.';
    END IF;
END //
DELIMITER ;

-- Trigger 4: Log de missões criadas
CREATE TABLE log_missoes (
    id_log INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100),
    data_criacao DATETIME
);

DELIMITER //
CREATE TRIGGER trg_log_missao_nova
AFTER INSERT ON missoes
FOR EACH ROW
BEGIN
    INSERT INTO log_missoes (titulo, data_criacao)
    VALUES (NEW.titulo, NOW());
END //
DELIMITER ;

-- Trigger 5: Atualizar automaticamente o status de personagem para 'desaparecido' se missão atribuída for excluída
DELIMITER //
CREATE TRIGGER trg_personagem_missao_removida
AFTER DELETE ON missoes
FOR EACH ROW
BEGIN
    UPDATE personagens
    SET status = 'desaparecido'
    WHERE id_personagem = OLD.id_personagem_responsavel;
END //
DELIMITER ;

-- Views -- 
-- Mostra um resumo das missões com o nome do personagem responsável. --
CREATE VIEW vw_resumo_missoes AS
SELECT 
    m.titulo AS titulo_missao,
    m.recompensa,
    m.localizacao,
    p.nome AS personagem_responsavel
FROM missoes m
JOIN personagens p ON m.id_personagem_responsavel = p.id_personagem;

 -- Lista todas as armas junto com os dados do personagem que a possui. --
CREATE VIEW vw_armas_personagens AS
SELECT 
    a.nome_arma,
    a.tipo,
    a.dano,
    a.alcance,
    p.nome AS dono,
    p.status
FROM armas a
JOIN personagens p ON a.id_personagem_dono = p.id_personagem;

-- Mostra apenas os animais com perigo médio ou alto. --
CREATE VIEW vw_animais_perigosos AS
SELECT 
    nome_comum,
    tipo,
    perigo,
    pode_domesticar
FROM animais
WHERE perigo IN ('alta', 'média')
ORDER BY perigo DESC;


-- Tabela: Personagens
CREATE TABLE personagens (
    id_personagem INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    idade INT,
    papel_no_jogo VARCHAR(50), -- protagonista, antagonista, etc.
    status VARCHAR(20) -- vivo, morto, desaparecido
);

-- Tabela: Missões
CREATE TABLE missoes (
    id_missao INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(100) NOT NULL,
    descricao TEXT,
    recompensa VARCHAR(100),
    localizacao VARCHAR(100),
    id_personagem_responsavel INT,
    FOREIGN KEY (id_personagem_responsavel) REFERENCES personagens(id_personagem)
);

-- Tabela: Armas
CREATE TABLE armas (
    id_arma INT AUTO_INCREMENT PRIMARY KEY,
    nome_arma VARCHAR(100) NOT NULL,
    tipo VARCHAR(50), -- revolver, rifle, faca etc.
    dano INT,
    alcance INT,
    id_personagem_dono INT,
    FOREIGN KEY (id_personagem_dono) REFERENCES personagens(id_personagem)
);

-- Tabela: Locais
CREATE TABLE locais (
    id_local INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(100) NOT NULL,
    tipo_local VARCHAR(50), -- cidade, floresta, rancho etc.
    descricao TEXT,
    estado VARCHAR(50) -- exemplo: New Hanover
);

-- Tabela: Animais
CREATE TABLE animais (
    id_animal INT AUTO_INCREMENT PRIMARY KEY,
    nome_comum VARCHAR(100),
    tipo VARCHAR(50), -- selvagem, domesticado
    perigo VARCHAR(20), -- baixa, média, alta
    pode_domesticar BOOLEAN
);
--INSERTS

INSERT INTO personagens (nome, idade, papel_no_jogo, status) VALUES
('Arthur Morgan', 36, 'Protagonista', 'morto'),
('Dutch van der Linde', 45, 'Antagonista', 'desaparecido'),
('John Marston', 26, 'Aliado', 'vivo'),
('Sadie Adler', 30, 'Aliada', 'vivo'),
('Micah Bell', 35, 'Traidor', 'morto'),
('Hosea Matthews', 55, 'Mentor', 'morto'),
('Charles Smith', 28, 'Aliado', 'vivo'),
('Bill Williamson', 32, 'Aliado', 'vivo'),
('Javier Escuella', 30, 'Aliado', 'vivo'),
('Abigail Roberts', 25, 'Aliada', 'vivo'),
('Jack Marston', 12, 'Filho', 'vivo'),
('Tilly Jackson', 24, 'Aliada', 'vivo'),
('Leopold Strauss', 50, 'Agiota', 'expulso'),
('Reverend Swanson', 40, 'Padre', 'vivo'),
('Uncle', 50, 'Cômico', 'vivo'),
('Pearson', 38, 'Cozinheiro', 'vivo'),
('Lenny Summers', 22, 'Aliado', 'morto'),
('Sean MacGuire', 27, 'Aliado', 'morto'),
('Mary-Beth Gaskill', 25, 'Aliada', 'vivo'),
('Susan Grimshaw', 40, 'Líder feminina', 'morta');



INSERT INTO missoes (titulo, descricao, recompensa, localizacao, id_personagem_responsavel) VALUES
('Quem é Leviticus Cornwall?', 'Assalte um trem de carga.', 'Dinheiro e honra', 'Valentine', 1),
('A batalha de Shady Belle', 'Ataque um esconderijo inimigo.', 'Acesso ao novo acampamento', 'Lemoyne', 2),
('Caçada ao tesouro', 'Siga pistas para encontrar ouro.', 'Barras de ouro', 'Annesburg', 6),
('Roubo ao banco', 'Assalte o banco com John e Sadie.', 'Dinheiro', 'Saint Denis', 3),
('Perseguindo o traidor', 'Descubra os planos de Micah.', 'Informação importante', 'Mount Hagen', 1),
('Salve Sean', 'Resgate Sean de bounty hunters.', 'Confiança da gangue', 'Strawberry', 7),
('Fim da linha', 'Confronte Dutch e Micah.', 'Justiça', 'Beaver Hollow', 3),
('O roubo do trem', 'Assalte um trem federal.', 'Dinheiro', 'Rhodes', 1),
('Ajude Mary-Beth', 'Leve Mary até a estação.', 'Confiança', 'Rhodes', 1),
('Caminho para a liberdade', 'Ajude escravos fugitivos.', 'Respeito', 'Saint Denis', 7),
('Ataque ao rancho', 'Ajude Sadie a vingar Jake.', 'Armas novas', 'Scarlett Meadows', 4),
('Carta de amor', 'Entregue carta de Mary.', 'Relíquias', 'Valentine', 1),
('A vingança de Charles', 'Destrua o acampamento inimigo.', 'Honra', 'Wapiti', 6),
('Bandidos no trem', 'Detenha os ladrões.', 'Recompensa', 'Emerald Ranch', 3),
('Alvo em fuga', 'Capture um bandido.', 'Dinheiro', 'Blackwater', 3),
('Expulsando os Pinkertons', 'Resista a uma emboscada.', 'Sobrevivência', 'Clemens Point', 2),
('Missão diplomática', 'Converse com os indígenas.', 'Aliança', 'Wapiti', 7),
('A última dança', 'Ajude a fuga final.', 'Liberdade', 'New Austin', 3),
('Colheita perigosa', 'Proteja o campo dos lobos.', 'Comida', 'Grizzlies', 14),
('Fuga de trem', 'Escape de uma emboscada.', 'Sobrevivência', 'Saint Denis', 5);


INSERT INTO armas (nome_arma, tipo, dano, alcance, id_personagem_dono) VALUES
('Revolver Cattleman', 'Revólver', 50, 30, 1),
('Lancaster Repeater', 'Rifle', 70, 80, 3),
('Faca de Caça', 'Faca', 40, 2, 1),
('Shotgun de Cano Duplo', 'Espingarda', 90, 20, 4),
('Revolver Schofield', 'Revólver', 55, 35, 5),
('Carabina de Precisão', 'Rifle', 80, 100, 7),
('Arco Comum', 'Arco', 60, 50, 6),
('Mauser Pistol', 'Pistola', 60, 40, 3),
('Dynamite', 'Explosivo', 100, 10, 2),
('Springfield Rifle', 'Rifle', 85, 90, 8),
('Tomahawk', 'Arremesso', 65, 20, 6),
('Rolling Block Rifle', 'Sniper', 100, 150, 7),
('Faca Cerimonial', 'Faca', 30, 3, 9),
('Revólver duplo', 'Revólver', 50, 30, 1),
('Winchester Repeater', 'Rifle', 75, 70, 3),
('Espingarda de Cano Serrado', 'Espingarda', 80, 15, 4),
('Revolver Navy', 'Revólver', 60, 30, 5),
('Arco de Caça', 'Arco', 65, 45, 6),
('Molotov', 'Explosivo', 90, 15, 2),
('Revólver de Ouro', 'Revólver', 55, 30, 1);


INSERT INTO locais (nome, tipo_local, descricao, estado) VALUES
('Valentine', 'Cidade', 'Cidade com clima frio e bares', 'New Hanover'),
('Strawberry', 'Cidade', 'Pequena vila montanhosa', 'West Elizabeth'),
('Saint Denis', 'Cidade', 'Grande metrópole industrial', 'Lemoyne'),
('Rhodes', 'Cidade', 'Centro rural com plantações', 'Lemoyne'),
('Blackwater', 'Cidade', 'Cidade moderna à beira do rio', 'West Elizabeth'),
('Grizzlies', 'Montanhas', 'Montanhas frias e selvagens', 'Ambarino'),
('Wapiti', 'Aldeia', 'Aldeia indígena em conflito', 'Ambarino'),
('Clemens Point', 'Acampamento', 'Acampamento na floresta', 'Lemoyne'),
('Horseshoe Overlook', 'Acampamento', 'Acampamento na montanha', 'New Hanover'),
('Emerald Ranch', 'Rancho', 'Rancho com mercado negro', 'New Hanover'),
('Mount Hagen', 'Montanha', 'Pico nevado isolado', 'Ambarino'),
('Annesburg', 'Cidade', 'Cidade com mineração de carvão', 'New Hanover'),
('Lagras', 'Aldeia', 'Povoado no pântano', 'Lemoyne'),
('Beecher’s Hope', 'Rancho', 'Fazenda de John Marston', 'West Elizabeth'),
('Colter', 'Aldeia', 'Região inicial do jogo', 'Ambarino'),
('Van Horn', 'Porto', 'Cidade portuária decadente', 'New Hanover'),
('Tumbleweed', 'Cidade', 'Cidade do velho oeste', 'New Austin'),
('Armadillo', 'Cidade', 'Cidade desértica em declínio', 'New Austin'),
('Fort Wallace', 'Forte', 'Base militar antiga', 'Ambarino'),
('Dakota River', 'Rio', 'Rio principal que corta o mapa', 'New Hanover');


INSERT INTO animais (nome_comum, tipo, perigo, pode_domesticar) VALUES
('Cervo', 'Selvagem', 'baixa', FALSE),
('Urso Pardo', 'Selvagem', 'alta', FALSE),
('Cavalo Árabe', 'Domesticado', 'baixa', TRUE),
('Puma', 'Selvagem', 'alta', FALSE),
('Cão de caça', 'Domesticado', 'baixa', TRUE),
('Jacaré', 'Selvagem', 'alta', FALSE),
('Alce', 'Selvagem', 'média', FALSE),
('Lobo', 'Selvagem', 'média', FALSE),
('Galo', 'Domesticado', 'baixa', TRUE),
('Ganso', 'Selvagem', 'baixa', FALSE),
('Águia', 'Selvagem', 'média', FALSE),
('Javali', 'Selvagem', 'média', FALSE),
('Raposa', 'Selvagem', 'baixa', FALSE),
('Cavalo Mustang', 'Domesticado', 'baixa', TRUE),
('Coiote', 'Selvagem', 'média', FALSE),
('Touro', 'Domesticado', 'média', TRUE),
('Corvo', 'Selvagem', 'baixa', FALSE),
('Cavalo Morgan', 'Domesticado', 'baixa', TRUE),
('Urso Negro', 'Selvagem', 'alta', FALSE),
('Pato Selvagem', 'Selvagem', 'baixa', FALSE);

-- crud --

remove from animais where perigo like "alta";
update locais set nome = "Strawberry Hills" where nome like "Strawberry";
select * from missoes where descricao like "Ataque um esconderijo inimigo.";

-- Roles -- 
CREATE ROLE 'role_admin';
GRANT ALL PRIVILEGES ON *.* TO 'role_admin';

CREATE ROLE 'role_analista';
GRANT SELECT, INSERT, UPDATE, EXECUTE ON *.* TO 'role_analista';

-- Usuários -- 
GRANT 'role_admin' TO 'matheus'@'%';
GRANT 'role_analista' TO 'ana'@'%';

-- Stores Procedures
-- Lista todas as missões de um personagem específico
DELIMITER 
CREATE PROCEDURE sp_missoes_por_personagem(IN personagem_id INT)
BEGIN
    SELECT m.titulo, m.descricao, m.recompensa, m.localizacao
    FROM missoes m
    WHERE m.id_personagem_responsavel = personagem_id;
END 
DELIMITER ;

-- Lista armas de um tipo específico com filtro de dano mínimo
DELIMITER //
CREATE PROCEDURE sp_armas_por_tipo(IN tipo_arma VARCHAR(50), IN dano_minimo INT)
BEGIN
    SELECT a.nome_arma, a.dano, a.alcance, p.nome AS dono
    FROM armas a
    JOIN personagens p ON a.id_personagem_dono = p.id_personagem
    WHERE a.tipo = tipo_arma AND a.dano >= dano_minimo;
END //
DELIMITER ;

-- Lista animais perigosos com possibilidade de filtro por tipo
DELIMITER //
CREATE PROCEDURE sp_atualizar_status_personagem(IN personagem_id INT, IN novo_status VARCHAR(20))
BEGIN
    UPDATE personagens 
    SET status = novo_status 
    WHERE id_personagem = personagem_id;
END //
DELIMITER ;

-- Lista de animais perigosos
DELIMITER //
CREATE PROCEDURE sp_animais_perigosos(IN tipo_animal VARCHAR(50))
BEGIN
    IF tipo_animal IS NULL THEN
        SELECT nome_comum, tipo, perigo
        FROM animais
        WHERE perigo IN ('alta', 'média')
        ORDER BY perigo DESC;
    ELSE
        SELECT nome_comum, tipo, perigo
        FROM animais
        WHERE perigo IN ('alta', 'média') AND tipo = tipo_animal
        ORDER BY perigo DESC;
    END IF;
END //
DELIMITER ;

-- Chamada das procedures
CALL sp_missoes_por_personagem(1);
CALL sp_armas_por_tipo('Revólver', 50);
CALL sp_atualizar_status_personagem(3, 'morto');
CALL sp_animais_perigosos(NULL);

-- Functions
CREATE FUNCTION verificar_se_missao_foi_concluida(id_personagem INT, id_missao INT)
RETURNS BOOLEAN
BEGIN
    DECLARE resultado INT;

    SELECT COUNT(*) INTO resultado
    FROM missoes
    WHERE id_personagem_responsavel = id_personagem
    AND id_missao = id_missao
    AND recompensa IS NOT NULL;  
    
    IF resultado > 0 THEN
        RETURN TRUE;
    ELSE
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Missão não foi concluída';
    END IF;
END $$


DELIMITER $$
CREATE FUNCTION calcular_missoes_concluidas(id_personagem INT)
RETURNS INT
BEGIN
    DECLARE num_missoes INT;
    
    SELECT COUNT(*) INTO num_missoes 
    FROM missoes 
    WHERE id_personagem_responsavel = id_personagem 
    AND recompensa IS NOT NULL;  
    
    RETURN num_missoes;
END $$
DELIMITER ;

-- Trigger 

-- Trigger para evitar que um personagem seja excluído se estiver associado a missões
DELIMITER
CREATE TRIGGER impedir_missao_personagem_morto
BEFORE INSERT ON missoes
FOR EACH ROW
BEGIN
    DECLARE status_personagem VARCHAR(20);
    SELECT status INTO status_personagem
    FROM personagens
    WHERE id_personagem = NEW.id_personagem_responsavel;

    IF status_personagem = 'morto' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível atribuir missão a um personagem morto.';
    END IF;
END;
DELIMITER ;

--Trigger para garantir que a recompensa de uma missão não seja nula
DELIMITER $$
CREATE TRIGGER check_recompensa_missao
BEFORE INSERT ON missoes
FOR EACH ROW
BEGIN
    IF NEW.recompensa IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Recompensa da missão não pode ser nula.';
    END IF;
END $$
DELIMITER ;

--Trigger para evitar que o valor do dano de uma arma seja negativo
DELIMITER $$
CREATE TRIGGER check_arma_dano_negativo
BEFORE INSERT ON armas
FOR EACH ROW
BEGIN

    IF NEW.dano < 0 THEN
        SIGNAL SQLSTATE '45000' 
    SET MESSAGE_TEXT = 'O valor de dano não pode ser negativo.';
    END IF;
END $$
DELIMITER ;


--Trigger para deletar armas automaticamente quando um personagem for deletado
DELIMITER 
CREATE TRIGGER deletar_armas_personagem
AFTER DELETE ON personagens
FOR EACH ROW
BEGIN
    DELETE FROM armas WHERE id_personagem_dono = OLD.id_personagem;
END;
DELIMITER ;

--Trigger mpedir inserção de animal domesticado com nível de perigo "alta"
DELIMITER //
CREATE TRIGGER valida_domesticacao_animal
BEFORE INSERT ON animais
FOR EACH ROW
BEGIN
    IF NEW.pode_domesticar = TRUE AND NEW.perigo = 'alta' THEN
        SET NEW.nome_comum = NULL;
        SET NEW.tipo = NULL;
        SET NEW.perigo = NULL;
        SET NEW.pode_domesticar = NULL;
    END IF;
END;
//
DELIMITER ;

-- triggers implementadas foi para atualizar o status de um  personagem após a missão
 DELIMITER //
 CREATE TRIGGER atualizar_status_personagem
 AFTER UPDATE ON missoes
 FOR EACH ROW
 BEGIN
     IF NEW.status = ’completa’ THEN
         UPDATE personagens
         SET status = ’vivo’
         WHERE id_personagem = NEW.id_personagem_responsavel;
     END IF;
 END //
 DELIMITER ;

 -- View
--View para listar os personagens com suas missões concluídas
CREATE VIEW personagens_missoes_concluidas AS
SELECT 
    p.nome AS personagem_nome,
    p.idade,
    m.titulo AS missao_titulo,
    m.recompensa,
    m.localizacao
FROM 
    personagens p
JOIN 
    missoes m ON p.id_personagem = m.id_personagem_responsavel
WHERE 
    m.recompensa IS NOT NULL;

-- View que mostra missões com o nome do personagem responsável e a recompensa.
CREATE VIEW view_missoes_detalhadas AS
SELECT 
    m.titulo,
    m.descricao,
    m.recompensa,
    m.localizacao,
    p.nome AS responsavel
FROM missoes m
JOIN personagens p ON m.id_personagem_responsavel = p.id_personagem;

--View que mostra apenas animais que podem ser domesticados.
CREATE VIEW view_animais_domesticaveis AS
SELECT 
    nome_comum,
    tipo,
    perigo
FROM animais
WHERE pode_domesticar = TRUE;

--View consulta das missões de cada personagem
CREATE VIEW missoes_por_personagem AS
 SELECT m.titulo, m.descricao, m.recompensa, p.nome
 FROM missoes m
 JOIN personagens p ON m.id_personagem_responsavel = p.
 id_personagem;

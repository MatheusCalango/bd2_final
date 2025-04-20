-- Tabela: Personagens
CREATE TABLE personagens (
SELECT * FROM personagens;
SELECT * FROM armas;
SELECT * FROM missoes;
SELECT * FROM animais;
SELECT * FROM locais;

sp_missoes_por_personagem - Lista todas as missões de um personagem específico

DELIMITER //
CREATE PROCEDURE sp_missoes_por_personagem(IN personagem_id INT)
BEGIN
    SELECT m.titulo, m.descricao, m.recompensa, m.localizacao
    FROM missoes m
    WHERE m.id_personagem_responsavel = personagem_id;
END //
DELIMITER ; 
sp_armas_por_tipo - Lista armas de um tipo específico com filtro de dano mínimo

DELIMITER //
CREATE PROCEDURE sp_armas_por_tipo(IN tipo_arma VARCHAR(50), IN dano_minimo INT)
BEGIN
    SELECT a.nome_arma, a.dano, a.alcance, p.nome AS dono
    FROM armas a
    JOIN personagens p ON a.id_personagem_dono = p.id_personagem
    WHERE a.tipo = tipo_arma AND a.dano >= dano_minimo;
END //
DELIMITER ; 
sp_atualizar_status_personagem - Atualiza o status de um personagem

DELIMITER //
CREATE PROCEDURE sp_atualizar_status_personagem(IN personagem_id INT, IN novo_status VARCHAR(20))
BEGIN
    UPDATE personagens 
    SET status = novo_status 
    WHERE id_personagem = personagem_id;
END //
DELIMITER ;
sp_animais_perigosos - Lista animais perigosos com possibilidade de filtro por tipo

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
﻿
CREATE DATABASE red_dead_redemption2;
USE red_dead_redemption2;


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
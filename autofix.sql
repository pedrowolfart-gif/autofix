CREATE TABLE clientes (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) UNIQUE NOT NULL,
    telefone VARCHAR(20) NOT NULL,
    cpf VARCHAR(11) UNIQUE NOT NULL,
    data_cadastro TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE mecanicos (
    id SERIAL PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,
    valor_hora DECIMAL(10, 2) NOT NULL,
    CHECK (valor_hora > 0)
);

CREATE TABLE veiculos (
    id SERIAL PRIMARY KEY,
    cliente_id INTEGER NOT NULL,
    placa VARCHAR(7) UNIQUE NOT NULL,
    modelo VARCHAR(100) NOT NULL,
    marca VARCHAR(100) NOT NULL,
    ano INTEGER NOT NULL,
    FOREIGN KEY (cliente_id) REFERENCES clientes(id)
);

CREATE TABLE ordens_servico (
    id SERIAL PRIMARY KEY,
    veiculo_id INTEGER NOT NULL,
    mecanico_id INTEGER NOT NULL,
    data_abertura TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    valor_mao_obra DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status VARCHAR(20) NOT NULL DEFAULT 'Em Aberto',
    FOREIGN KEY (veiculo_id) REFERENCES veiculos(id),
    FOREIGN KEY (mecanico_id) REFERENCES mecanicos(id),
    CHECK (valor_mao_obra >= 0),
    CHECK (status IN ('Em Aberto', 'Em Andamento', 'Concluida', 'Cancelada'))
);

CREATE TABLE pecas_os (
    id SERIAL PRIMARY KEY,
    os_id INTEGER NOT NULL,
    nome_peca VARCHAR(150) NOT NULL,
    quantidade INTEGER NOT NULL,
    valor_unitario DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (os_id) REFERENCES ordens_servico(id),
    CHECK (quantidade > 0),
    CHECK (valor_unitario > 0)
);


INSERT INTO clientes (nome, email, telefone, cpf) VALUES
('Fernanda Lima', 'fernanda.lima@email.com', '11988887777', '12345678901'),
('Carlos Eduardo', 'carlos.eduardo@email.com', '11977776666', '23456789012'),
('Mariana Souza', 'mariana.souza@email.com', '11966665555', '34567890123');

INSERT INTO mecanicos (nome, especialidade, valor_hora) VALUES
('Roberto Santos', 'Motor', 120.00),
('João Pereira', 'Suspensão', 85.00),
('Lucas Andrade', 'Injeção Eletrônica', 110.00);

INSERT INTO veiculos (cliente_id, placa, modelo, marca, ano) VALUES
(1, 'ABC1D23', 'Civic', 'Honda', 2020),
(2, 'XYZ9K88', 'Corolla', 'Toyota', 2021),
(3, 'MNO5T44', 'Gol', 'Volkswagen', 2018);

INSERT INTO ordens_servico (veiculo_id, mecanico_id, valor_mao_obra, status) VALUES
(1, 1, 350.00, 'Concluida'),
(1, 3, 200.00, 'Em Andamento'),
(2, 2, 180.00, 'Concluida'),
(3, 1, 400.00, 'Cancelada');

INSERT INTO pecas_os (os_id, nome_peca, quantidade, valor_unitario) VALUES
(1, 'Filtro de Óleo', 1, 45.00),
(1, 'Óleo Sintético 5W30', 4, 60.00),
(2, 'Vela de Ignição', 4, 35.00),
(3, 'Amortecedor Dianteiro', 2, 350.00);

SELECT 
    v.modelo,
    v.marca,
    v.placa,
    c.nome AS proprietario,
    c.telefone
FROM veiculos v
JOIN clientes c 
    ON v.cliente_id = c.id
ORDER BY v.marca ASC, v.modelo ASC;

SELECT 
    os.id AS id_os,
    v.placa,
    v.modelo,
    os.data_abertura,
    m.nome AS mecanico,
    os.status
FROM ordens_servico os
JOIN veiculos v 
    ON os.veiculo_id = v.id
JOIN clientes c 
    ON v.cliente_id = c.id
JOIN mecanicos m 
    ON os.mecanico_id = m.id
WHERE c.nome = 'Fernanda Lima'
ORDER BY os.data_abertura DESC;

SELECT 
    os.id AS id_os,
    v.placa,
    m.nome AS mecanico,
    os.valor_mao_obra,
    COALESCE(SUM(p.quantidade * p.valor_unitario), 0) AS valor_pecas,
    os.valor_mao_obra + COALESCE(SUM(p.quantidade * p.valor_unitario), 0) AS valor_total_final
FROM ordens_servico os
JOIN veiculos v 
    ON os.veiculo_id = v.id
JOIN mecanicos m 
    ON os.mecanico_id = m.id
LEFT JOIN pecas_os p 
    ON os.id = p.os_id
GROUP BY os.id, v.placa, m.nome, os.valor_mao_obra
ORDER BY os.id ASC;

SELECT 
    nome AS mecanico,
    especialidade,
    valor_hora
FROM mecanicos
WHERE valor_hora > 90.00
ORDER BY valor_hora DESC;

SELECT 
    m.especialidade,
    SUM(os.valor_mao_obra) AS total_faturado_mao_obra
FROM ordens_servico os
JOIN mecanicos m 
    ON os.mecanico_id = m.id
WHERE os.status = 'Concluida'
GROUP BY m.especialidade
ORDER BY total_faturado_mao_obra DESC;
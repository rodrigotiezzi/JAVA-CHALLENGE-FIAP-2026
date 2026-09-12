/*

Banco de dados relacionado a app Java - Clyvo (Adaptado para Azure SQL)
Script de referencia/manual. O Hibernate (spring.jpa.hibernate.ddl-auto=update)
ja cria essas tabelas automaticamente ao subir a aplicacao.

*/

/*DROPS*/
DROP TABLE IF EXISTS tb_pet_tutor;
DROP TABLE IF EXISTS tb_consulta;
DROP TABLE IF EXISTS tb_agendamento;
DROP TABLE IF EXISTS tb_vet;
DROP TABLE IF EXISTS tb_pet;
DROP TABLE IF EXISTS tb_tutor;

/*DDL*/
CREATE TABLE tb_tutor (
    id_tutor INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(70) NOT NULL,
    idade INT,
    endereco VARCHAR(255),
    num_telefone VARCHAR(20),
    cpf VARCHAR(14) NOT NULL,
    CONSTRAINT uq_tutor_cpf UNIQUE (cpf)
);

CREATE TABLE tb_pet (
    id_pet INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(50),
    especie VARCHAR(50) NOT NULL,
    raca VARCHAR(50),
    cor VARCHAR(50),
    idade INT,
    peso DECIMAL(6,2)
);

CREATE TABLE tb_pet_tutor (
    id_pet INT NOT NULL,
    id_tutor INT NOT NULL,
    CONSTRAINT pk_pet_tutor PRIMARY KEY (id_pet, id_tutor),
    CONSTRAINT fk_pet_tutor_pet FOREIGN KEY (id_pet) REFERENCES tb_pet (id_pet),
    CONSTRAINT fk_pet_tutor_tutor FOREIGN KEY (id_tutor) REFERENCES tb_tutor (id_tutor)
);

CREATE TABLE tb_vet (
    id_vet INT IDENTITY(1,1) PRIMARY KEY,
    nome VARCHAR(70),
    area VARCHAR(40),
    crmv_prefixo VARCHAR(10) DEFAULT 'CRMV',
    crmv_uf VARCHAR(2) NOT NULL,
    crmv_numinscricao INT NOT NULL,
    crmv_sufixo VARCHAR(2),
    CONSTRAINT uq_vet_crmv UNIQUE (crmv_uf, crmv_numinscricao)
);

CREATE TABLE tb_agendamento (
    id_agendamento INT IDENTITY(1,1) PRIMARY KEY,
    dt_hora DATETIME2 NOT NULL,
    id_pet INT NOT NULL,
    id_vet INT NOT NULL,
    status VARCHAR(20) NOT NULL,
    motivo VARCHAR(255),
    CONSTRAINT fk_agendamento_pet FOREIGN KEY (id_pet) REFERENCES tb_pet (id_pet),
    CONSTRAINT fk_agendamento_vet FOREIGN KEY (id_vet) REFERENCES tb_vet (id_vet)
);

CREATE TABLE tb_consulta (
    id_consulta INT IDENTITY(1,1) PRIMARY KEY,
    id_agendamento INT,
    dt_realizacao DATETIME2 NOT NULL,
    diagnostico VARCHAR(500) NOT NULL,
    tratamento VARCHAR(500),
    observacoes VARCHAR(500),
    CONSTRAINT fk_consulta_agendamento FOREIGN KEY (id_agendamento) REFERENCES tb_agendamento (id_agendamento)
);

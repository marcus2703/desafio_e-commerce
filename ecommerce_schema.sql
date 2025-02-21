CREATE SCHEMA IF NOT EXISTS `mydb` DEFAULT CHARACTER SET utf8;
USE `mydb`;

-- Tabela cliente
CREATE TABLE IF NOT EXISTS `mydb`.`cliente` (
  `id_cliente` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `endereco` VARCHAR(255) NOT NULL,
  `tipo_cliente` ENUM('Pessoa Física', 'Pessoa Jurídica') NOT NULL,
  `cpf` VARCHAR(45) NULL,
  `cnpj` VARCHAR(45) NULL,
  `razao_social` VARCHAR(45) NULL,
  PRIMARY KEY (`id_cliente`),
  -- Verificação de consistência dos dados
  CONSTRAINT chk_cliente_tipo CHECK (
    (tipo_cliente = 'Pessoa Física' AND cpf IS NOT NULL AND cnpj IS NULL AND razao_social IS NULL) OR
    (tipo_cliente = 'Pessoa Jurídica' AND cnpj IS NOT NULL AND cpf IS NULL AND razao_social IS NOT NULL)
  ))
ENGINE = InnoDB;

-- Tabela cartao_credito
CREATE TABLE IF NOT EXISTS `mydb`.`cartao_credito` (
  `id_cartao` INT NOT NULL AUTO_INCREMENT,
  `numero_cartao` VARCHAR(20) NOT NULL,
  `bandeira` VARCHAR(20) NOT NULL,
  `validade` DATE NOT NULL,
  PRIMARY KEY (`id_cartao`));

-- Tabela transportadora
CREATE TABLE IF NOT EXISTS `mydb`.`transportadora` (
  `id_transportadora` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `cnpj` VARCHAR(20) NOT NULL,
  UNIQUE INDEX (`cnpj` ASC) VISIBLE,
  PRIMARY KEY (`id_transportadora`));

-- Tabela armazem
CREATE TABLE IF NOT EXISTS `mydb`.`armazem` (
  `id_armazem` INT NOT NULL AUTO_INCREMENT,
  `localizacao` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id_armazem`))
ENGINE = InnoDB;

-- Tabela fornecedor
CREATE TABLE IF NOT EXISTS `mydb`.`fornecedor` (
  `id_fornecedor` INT NOT NULL AUTO_INCREMENT,
  `razao_social` VARCHAR(100) NOT NULL,
  `cnpj` VARCHAR(20) NOT NULL,
  UNIQUE INDEX (`cnpj` ASC) VISIBLE,
  PRIMARY KEY (`id_fornecedor`))
ENGINE = InnoDB;

-- Tabela vendedor
CREATE TABLE IF NOT EXISTS `mydb`.`vendedor` (
  `id_vendedor` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `cnpj` VARCHAR(20) NOT NULL,
  UNIQUE INDEX (`cnpj` ASC) VISIBLE,
  PRIMARY KEY (`id_vendedor`));

-- Tabela produto
CREATE TABLE IF NOT EXISTS `mydb`.`produto` (
  `id_produto` INT NOT NULL AUTO_INCREMENT,
  `nome` VARCHAR(100) NOT NULL,
  `descricao` TEXT NOT NULL,
  `categoria` VARCHAR(50) NOT NULL,
  `valor` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id_produto`))
ENGINE = InnoDB;

-- Tabela estoque
CREATE TABLE IF NOT EXISTS `mydb`.`estoque` (
  `id_armazem` INT NOT NULL,
  `id_produto` INT NOT NULL,
  `quantidade` INT NOT NULL,
  PRIMARY KEY (`id_armazem`, `id_produto`),
  INDEX (`id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_estoque_armazem`
    FOREIGN KEY (`id_armazem`)
    REFERENCES `mydb`.`armazem` (`id_armazem`),
  CONSTRAINT `fk_estoque_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `mydb`.`produto` (`id_produto`));

-- Tabela pedido
CREATE TABLE IF NOT EXISTS `mydb`.`pedido` (
  `id_pedido` INT NOT NULL AUTO_INCREMENT,
  `data_pedido` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `status_pedido` ENUM('Confirmado', 'Aguardando Pagamento', 'Pagamento Aprovado', 'Pagamento Reprovado', 'Enviado', 'Recebido', 'Cancelado', 'Devolvido') NOT NULL DEFAULT 'Aguardando Pagamento',
  `valor_frete` FLOAT NOT NULL,
  `forma_pagamento` VARCHAR(45) NULL,
  `cliente_id_cliente` INT NOT NULL,
  PRIMARY KEY (`id_pedido`, `cliente_id_cliente`),
  INDEX `fk_pedido_cliente1_idx` (`cliente_id_cliente` ASC) VISIBLE,
  CONSTRAINT `fk_pedido_cliente1`
    FOREIGN KEY (`cliente_id_cliente`)
    REFERENCES `mydb`.`cliente` (`id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

-- Tabela pedido_produto
CREATE TABLE IF NOT EXISTS `mydb`.`pedido_produto` (
  `id_pedido` INT NOT NULL,
  `id_produto` INT NOT NULL,
  `quantidade` INT NOT NULL,
  PRIMARY KEY (`id_pedido`, `id_produto`),
  INDEX (`id_produto` ASC) VISIBLE,
  CONSTRAINT `fk_pedido_produto_pedido`
    FOREIGN KEY (`id_pedido`)
    REFERENCES `mydb`.`pedido` (`id_pedido`),
  CONSTRAINT `fk_pedido_produto_produto`
    FOREIGN KEY (`id_produto`)
    REFERENCES `mydb`.`produto` (`id_produto`));

-- Tabela produto_por_fornecedor
CREATE TABLE IF NOT EXISTS `mydb`.`produto_por_fornecedor` (
  `fornecedor_id_fornecedor` INT NOT NULL,
  `produto_id_produto` INT NOT NULL,
  PRIMARY KEY (`fornecedor_id_fornecedor`, `produto_id_produto`),
  INDEX `fk_fornecedor_has_produto_produto1_idx` (`produto_id_produto` ASC) VISIBLE,
  INDEX `fk_fornecedor_has_produto_fornecedor1_idx` (`fornecedor_id_fornecedor` ASC) VISIBLE,
  CONSTRAINT `fk_fornecedor_has_produto_fornecedor1`
    FOREIGN KEY (`fornecedor_id_fornecedor`)
    REFERENCES `mydb`.`fornecedor` (`id_fornecedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_fornecedor_has_produto_produto1`
    FOREIGN KEY (`produto_id_produto`)
    REFERENCES `mydb`.`produto` (`id_produto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- Tabela produto_por_vendedor
CREATE TABLE IF NOT EXISTS `mydb`.`produto_por_vendedor` (
  `vendedor_id_vendedor` INT NOT NULL,
  `produto_id_produto` INT NOT NULL,
  `quantidade` INT NULL,
  PRIMARY KEY (`vendedor_id_vendedor`, `produto_id_produto`),
  INDEX `fk_vendedor_has_produto_produto1_idx` (`produto_id_produto` ASC) VISIBLE,
  INDEX `fk_vendedor_has_produto_vendedor1_idx` (`vendedor_id_vendedor` ASC) VISIBLE,
  CONSTRAINT `fk_vendedor_has_produto_vendedor1`
    FOREIGN KEY (`vendedor_id_vendedor`)
    REFERENCES `mydb`.`vendedor` (`id_vendedor`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_vendedor_has_produto_produto1`
    FOREIGN KEY (`produto_id_produto`)
    REFERENCES `mydb`.`produto` (`id_produto`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- Tabela cliente_cartao_credito
CREATE TABLE IF NOT EXISTS `mydb`.`cliente_cartao_credito` (
  `id_cliente` INT NOT NULL,
  `id_cartao` INT NOT NULL,
  PRIMARY KEY (`id_cliente`, `id_cartao`),
  INDEX (`id_cartao` ASC) VISIBLE,
  CONSTRAINT `fk_cliente_cartao_credito_cliente`
    FOREIGN KEY (`id_cliente`)
    REFERENCES `mydb`.`cliente` (`id_cliente`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_cliente_cartao_credito_cartao`
    FOREIGN KEY (`id_cartao`)
    REFERENCES `mydb`.`cartao_credito` (`id_cartao`)
    ON DELETE CASCADE);

-- Tabela historico_status_pedido
CREATE TABLE IF NOT EXISTS `mydb`.`historico_status_pedido` (
  `id_historico` INT NOT NULL AUTO_INCREMENT,
  `status_pedido` ENUM('Confirmado', 'Aguardando Pagamento', 'Pagamento Aprovado', 'Pagamento Reprovado', 'Enviado', 'Recebido', 'Cancelado', 'Devolvido') NOT NULL,
  `data_status` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pedido_id_pedido` INT NOT NULL,
  `pedido_cliente_id_cliente` INT NOT NULL,
  PRIMARY KEY (`id_historico`, `pedido_id_pedido`, `pedido_cliente_id_cliente`),
  INDEX `fk_historico_status_pedido_pedido1_idx` (`pedido_id_pedido` ASC, `pedido_cliente_id_cliente` ASC) VISIBLE,
  CONSTRAINT `fk_historico_status_pedido_pedido1`
    FOREIGN KEY (`pedido_id_pedido`, `pedido_cliente_id_cliente`)
    REFERENCES `mydb`.`pedido` (`id_pedido`, `cliente_id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- Tabela pedido_por_trasportadora
CREATE TABLE IF NOT EXISTS `mydb`.`pedido_por_trasportadora` (
  `transportadora_id_transportadora` INT NOT NULL,
  `pedido_id_pedido` INT NOT NULL,
  `status` VARCHAR(45) NULL,
  `cod_rastreio` VARCHAR(45) NULL,
  PRIMARY KEY (`transportadora_id_transportadora`, `pedido_id_pedido`),
  INDEX `fk_transportadora_has_pedido_pedido1_idx` (`pedido_id_pedido` ASC) VISIBLE,
  INDEX `fk_transportadora_has_pedido_transportadora1_idx` (`transportadora_id_transportadora` ASC) VISIBLE,
  CONSTRAINT `fk_transportadora_has_pedido_transportadora1`
    FOREIGN KEY (`transportadora_id_transportadora`)
    REFERENCES `mydb`.`transportadora` (`id_transportadora`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_transportadora_has_pedido_pedido1`
    FOREIGN KEY (`pedido_id_pedido`)
    REFERENCES `mydb`.`pedido` (`id_pedido`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);

-- Tabela historico_status_transportadora
CREATE TABLE IF NOT EXISTS `mydb`.`historico_status_transportadora` (
  `id_historico` INT NOT NULL AUTO_INCREMENT,
  `status_transportadora` VARCHAR(45) NOT NULL,
  `data_status` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `pedido_id_pedido` INT NOT NULL,
  `pedido_cliente_id_cliente` INT NOT NULL,
  PRIMARY KEY (`id_historico`, `pedido_id_pedido`, `pedido_cliente_id_cliente`),
  INDEX `fk_historico_status_transportadora_pedido1_idx` (`pedido_id_pedido` ASC, `pedido_cliente_id_cliente` ASC) VISIBLE,
  CONSTRAINT `fk_historico_status_transportadora_pedido1`
    FOREIGN KEY (`pedido_id_pedido`, `pedido_cliente_id_cliente`)
    REFERENCES `mydb`.`pedido` (`id_pedido`, `cliente_id_cliente`)
    ON DELETE NO ACTION
    ON UPDATE NO ACTION);
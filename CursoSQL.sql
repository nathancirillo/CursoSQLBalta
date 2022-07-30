-- Cria um BD
CREATE DATABASE [Cursos]

-- Troca o BD antes de dropá-lo
USE [master]

-- Apaga um BD
DROP DATABASE [Curso]

-- Script caso o banco esteja em uso ao tentar apagá-lo. Trocar nome banco
 USE [master];
 DECLARE @kill varchar(8000) = '';
 SELECT @kill = @kill + 'kill ' + CONVERT(varchar(5), session_id) FROM sys.dm_exec_sessions WHERE database_id = db_id('Curso')
 EXEC(@kill);
 DROP DATABASE [Curso]

-- Criando uma tabela simples
CREATE TABLE [Aluno](
    [Id] INT,
    [Nome] NVARCHAR(80),
    [Nascimento] DATETIME,
    [Active] BIT    
)


-- Alterando uma tabela para adicionar um campo
ALTER TABLE [Aluno] 
    ADD [Documento] NVARCHAR(11) 

-- Alterando uma tabela para remover um campo 
ALTER TABLE [Aluno]
    DROP COLUMN [Active]


-- Alterando o tipo de uma coluna já criada no BD
ALTER TABLE [Aluno]
    ALTER COLUMN [Documento] CHAR(11)

-- Apagando uma tabela existente no BD
DROP TABLE [Aluno]

-- Constraints (limitações): criando campos diretamente não há limitações, ou seja, por padrão é tudo null
-- Elas são a base dos BDs relacionais. Ex: deixar um campo como não sendo nulo 
-- Podemos usar a opção DEFAULT () na criação da tabela para definir um valor padrão para o campo ao inserir valores. Assim não teríamos nulo.
CREATE TABLE [Aluno](
    [Id] INT NOT NULL,
    [Nome] NVARCHAR(80) NOT NULL,
    [Nascimento] DATETIME NULL,
    [Ativo] BIT NOT NULL DEFAULT(0)     
)

-- Definindo uma constraint para que a coluna Active não seja nula 
ALTER TABLE [Aluno]
    ALTER COLUMN [Active] BIT NOT NULL


-- UNIQUE diz que o valor de uma coluna não pode se repetir
-- O campo Id, por exemplo, não pode ser igual nos registros 
-- Assim como o DEFAULT, ele deve ser definido no momento da criação da tabela. Não funciona no ALTER COLUMN
CREATE TABLE [Aluno](
    [Id] INT NOT NULL UNIQUE,
    [Nome] NVARCHAR(80) NOT NULL,
    [Email] NVARCHAR(180) NOT NULL UNIQUE,
    [Nascimento] DATETIME NULL,
    [Ativo] BIT NOT NULL DEFAULT(0)     
)

-- No exemplo acima definimos o ID como NOT NULL E UNIQUE
-- Uma forma melhor de trabalhar é defíni-lo como: PRIMARY KEY. Seu valor não pode ser nulo e deve ser único.
CREATE TABLE [Aluno](
    [Id] INT NOT NULL UNIQUE,
    [Nome] NVARCHAR(80) NOT NULL,
    [Email] NVARCHAR(180) NOT NULL UNIQUE,
    [Nascimento] DATETIME NULL,
    [Ativo] BIT NOT NULL DEFAULT(0),
    PRIMARY KEY ([Id])   
)

-- Outra possibilidade é criar chaves primárias compostas
-- Posso dizer, por exemplo, que a chave deverá ser feita pelo ID e pelo EMAIL
-- A inserção de dados só irá passar se ambos os valores forem diferentes dos registros já cadastrados (and)
-- Tabela com relacionamentos, por exemplo, livro/autor usa essa ideia de chave composta (autor + livro, por exemplo)
CREATE TABLE [Aluno](
    [Id] INT NOT NULL UNIQUE,
    [Nome] NVARCHAR(80) NOT NULL,
    [Email] NVARCHAR(180) NOT NULL UNIQUE,
    [Nascimento] DATETIME NULL,
    [Ativo] BIT NOT NULL DEFAULT(0),
    PRIMARY KEY ([Id],[Email])   
)

-- Caso tenha esquecido de acrescentar a PRIMARY KEY no momento da criação da tabela é possível usar o ALTER TABLE
ALTER TABLE [Aluno]
    ADD PRIMARY KEY([Id])

-- Para recriar uma restrição sem ter que dropar a tabela podemos excluí-la
-- Para isso usamos o ALTER TABLE em conjunto com a opção DROP CONSTRAINT
ALTER TABLE [Aluno]
    DROP CONSTRAINT [PK__Aluno__3214EC076D0B056B]
 

-- Para criar uma tabela já com um nome diferente do padrão para a constraint basta especificar
-- Usa-se o comando constraint. Isso serve tanto para PRIMARY KEY como para UNIQUE. Veja: 
CREATE TABLE [Aluno](
    [Id] INT,
    [Nome] NVARCHAR(80) NOT NULL,
    [Email] NVARCHAR(180) NOT NULL,
    [Nascimento] DATETIME NULL,
    [Ativo] BIT NOT NULL DEFAULT(0),
    CONSTRAINT [PK_Aluno] PRIMARY KEY ([Id]),
    CONSTRAINT [UQ_Aluno_Email] UNIQUE([Email])   
)


-- Agora irei criar uma tabela chamada Curso. Existe uma relação entre Aluno e Curso
-- Essa relação é expressa através de uma terceira tabela: ProgressoCurso que deve conter: o aluno, o curso e o seu progresso, por exemplo
-- A isso é dado o nome de tabela associativa, ela existe para ligar duas outras tabelas
-- A tabela ProgressoCurso expressa o relacionamento N par N, ou seja, 1 aluno pode fazer N cursos; e 1 curso pode ser feito por N alunos

CREATE TABLE [Curso](
    [Id] INT,
    [Nome] NVARCHAR(80) NOT NULL,
    CONSTRAINT [PK_Curso] PRIMARY KEY([Id]) 
)

CREATE TABLE [ProgressoCurso](
    [AlunoId] INT NOT NULL,
    [CursoId] INT NOT NULL,
    [Progresso] DECIMAL NOT NULL,
    [UltimaAtualizacao] DATETIME NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_ProgressoCurso] PRIMARY KEY ([AlunoId], [CursoId])
)

-- Podemos ter também uma outra tabela chamada categoria
-- Essa tabela terá um Id e um Nome
-- Nesse caso trata-se de um relacionamento 1 para N. 1 categoria pode estar em N cursos, mas 1 curso tem só 1 categoria
CREATE TABLE [Categoria](
    Id INT,
    Nome NVARCHAR(80) NOT NULL,
    CONSTRAINT [PK_Categoria] PRIMARY KEY ([Id])
)


-- Agora irei expressar a relação entre curso e categoria
-- Será adicionad o campo CategoriaId na tabela de Curso. Porém não posso colocar uma categoria que não existe
-- Para que seja adicionado, ela deve existir na tabela categoria. Aplicamos então uma: FOREIGN KEY 
-- Uma FOREIGN KEY é conhecida como chave estrangeira. Usamos sempre que há um relacionamento entre tabelas 
CREATE TABLE [Curso](
    [Id] INT,
    [Nome] NVARCHAR(80) NOT NULL,
    [CategoriaId] INT,
    CONSTRAINT [PK_Curso] PRIMARY KEY([Id]), 
    CONSTRAINT [FK_CursoCategoria] FOREIGN KEY ([CategoriaId]) REFERENCES [Categoria]([Id])
)

-- No SQL SERVER como em outros BDs existe a possibilidade de criar ÍNDICES
-- O índice ele não é visível, mas ajuda a organizar melhor os dados
-- Tende a deixar o INSERT mais lento, porém facilita muito a leitura dos dados
-- É recomendado criar um índice para todos os campos que são usados/pesquisados com mais frequência
-- Para verificar o índice criado veja a pasta: Indexes
-- Importante: chave primária e unique já são definidos por padrão como índices
CREATE INDEX [IX_Aluno_Email] ON [Aluno]([Email])

-- Apagando o índice criado anteriormente: 
DROP INDEX [IX_Aluno_Email] ON [Aluno]


-- IDENTITY - permite colocar um valor de incremento a cada inserção automaticamente
-- Dessa forma não precisa saber o último identificador de um registro 
-- No identity podemos usar parênteses especificando o seu ínicio e o seu incremento IDENTITY (1,1)
CREATE TABLE [Curso](
    [Id] INT IDENTITY(1,1),
    [Nome] NVARCHAR(80) NOT NULL,
    [CategoriaId] INT,
    CONSTRAINT [PK_Curso] PRIMARY KEY([Id]), 
    CONSTRAINT [FK_CursoCategoria] FOREIGN KEY ([CategoriaId]) REFERENCES [Categoria]([Id])
)

-- Caso não deseja trabalhar com IDENTITY pode usar o UNIQUEIDENTIFIER
-- UNIQUEIDENTIFIER irá gerar um GUID similar ao que podemos ver rodando o comando abaixo
SELECT NEWID()


-- GERADOR À PARTIR DA AULA SOBRE INSERT
CREATE DATABASE [Cursos]

USE [Cursos]

CREATE TABLE [Curso](
    [Id] INT IDENTITY,
    [Nome] NVARCHAR(80) NOT NULL,
    [CategoriaId] INT NOT NULL,
    CONSTRAINT [PK_Curso] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_CursoCategoria] FOREIGN KEY ([CategoriaId]) REFERENCES [Categoria]([Id])
)

CREATE TABLE [Categoria](
    [Id] INT IDENTITY,
    [Nome] NVARCHAR(80) NOT NULL,
    CONSTRAINT [PK_Categoria] PRIMARY KEY([Id])
)


-- Agora a ideia é inserir informações na tabela através do INSERT INTO
INSERT INTO [Categoria]([Nome])VALUES('Backend')
INSERT INTO [Categoria]([Nome])VALUES('Frontend')
INSERT INTO [Categoria]([Nome])VALUES('Mobile')

INSERT INTO [Curso]([Nome],[CategoriaId])VALUES('Fundamentos de C#',1)
INSERT INTO [Curso]([Nome],[CategoriaId])VALUES('Fundamentos de OOP',1)
INSERT INTO [Curso]([Nome],[CategoriaId])VALUES('Angular',2)
INSERT INTO [Curso]([Nome],[CategoriaId])VALUES('Flutter',3)

-- Inserindo dados na tabela sem precisar especificar os campos
-- No caso abaixo é necessário passar certinho na ordem
INSERT INTO [Curso]VALUES('Flutter e SQLite',3) 


-- SELECT: permite buscar informações que deseja nas tabelas do banco
-- Exemplo clássico: SELECT * FROM [Curso]
-- Se houver milhões de registros provavelmente irá travar o banco com *
-- Sempre execute usando o comando TOP para controlar a quantidade de registros desejada
SELECT TOP 2 * FROM [Curso]
-- Outra dica é sempre especificar somente os campos que precisa ao invés de trazer tudo (*)
SELECT [Id], [Nome] FROM [Curso]
-- Outro recuros interessante é o DISTINCT. Trará somente o que é diferente (distintos) 
-- Para isso todos os campos informados no SELECT serão analisados
SELECT DISTINCT [Nome] FROM [Categoria]


-- WHERE cláusula usada para fazer filtragem de dados
-- Operadores relacionais: =, >, <, <=, >=, <> ou !=
-- Operador lógicas: AND, OR e NOT
-- Operador IS: usado para saber, por exemplo, se uma categoria é nula.
SELECT [Id], [Nome], [CategoriaId]
FROM [Curso]
WHERE 
[Id] = 2 AND
[CategoriaId] = 1 AND
[Nome] IS NOT NULL


-- ORDER BY: possibilidade ordernar pelos campos informados
-- As ordenações sempre serão da esquerda para direita e devem ser separadas por vírgula
-- Esse comando pode ser usado com ASC (padrão) ou DESC
SELECT [Id],[Nome], [CategoriaId]
FROM [Curso]
ORDER BY [Nome] DESC
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


-- GERADO À PARTIR DA AULA SOBRE INSERT
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


-- UPDATE: possibilita realizar alterações de dados com base em uma condicional 
-- Após o SET definimos os valores que queremos alterar. Basta separar por vírgula para alterar vários compos simultaneamente
-- Atenção: caso não seja informado o WHERE todos os dados serão alterados
-- É sempre bom fazer o seguinte: criar uma transação antes de um UPDATE ou DELETE
-- Para isso usa-se: BEGIN TRAN ou BEGIN TRANSACTION
-- Após vem o comando desejado de UPDATE ou DELETE
-- No final é sempre bom deixar o ROLLBACK. Assim primeiro verá o nº de linhas afetadas
-- Se tudo estiver correto ai execute o COMMIT 

BEGIN TRANSACTION 
    UPDATE [Categoria] SET [Nome] = 'Azure' WHERE [Id] = 3
ROLLBACK

SELECT TOP 10 * FROM [Categoria]


-- DELETE: permite apagar registros da sua tabela
-- Funciona de forma similar ao UPDATE, sendo interessante usar transction em conjunto também
-- Não será possível apagar um registro que está sendo usado por outra tabela (chave estrangeira)
BEGIN TRAN 
DELETE FROM [Curso] WHERE [CategoriaId] = 3
DELETE FROM [Categoria] WHERE [Id] = 3
ROLLBACK

-- MIN(), MAX(), COUNT(), AVG() E SUM()
-- Nunca usar nenhuma dessas funções com *
-- AVG() e SUM() fazem mais sentido quando usados com valores

--MIN: sempre irá trazer o menor valor numérico da coluna informada
SELECT MIN([Id]) FROM [Categoria]
--MAX: sempre irá trazer o maior valor numérico da coluna informada
SELECT MAX([CategoriaId]) FROM [Curso]
--COUNT: irá contar o número de *itens não nulos* que temos na tabela
SELECT COUNT([Id]) FROM [Curso]
--AVG: tirá a média dos valores da coluna informada
SELECT AVG([Id]) FROM [Curso]
--SUM: retorna a soma dos valores da coluna informada 
SELECT SUM([CategoriaId]) FROM Curso WHERE Id > 2


-- LIKE: operador usado para procurar algo similar
-- Nem sempre o = será adequada, pois estará procurando exatamente
-- Usado em conjunto com o sinal de porcentagem. Exemplos: 
-- 'Fundamentos%' -> começa com fundamentos 
-- 'fundamentos%' -> termina com fundamentos
-- '%fundamentos%' -> contém fundamentos em qualquer parte
SELECT * FROM [Curso] WHERE [Nome] LIKE 'Fundamentos%'
SELECT * FROM [Curso] WHERE [Nome] LIKE '%de%'
SELECT * FROM [Curso] WHERE [Nome] LIKE '%C#'

-- IN: espera um array de valores para que possa comparar e trazer os que estão presentes na lista
-- Isso permite fazer consulta trazendo os valores especificados no range, como por exemplo IDs
SELECT * FROM [Curso] WHERE [Id] IN (1,3,5)

-- BETWEEN: permite buscar itens cujos valores estejam entre o intervalo definido
-- Dessa forma não é necessário especificar todos os valores como acontece com o IN
-- Pode ser usada para comparar data, mas deve ser fornecido o padrão do SQL SERVER: '2022-08-02' AND '2022-09-20' 
SELECT * FROM [Curso] WHERE [Id] BETWEEN 2 AND 4


-- ALIAS: é algo muito usado em junção de tabelas, pois como existem campos com mesmo nome podemos evitar conflitos nesses casos
-- Em consultas ao invés de trazer o proprio nome da coluna é possível trocar a sua identificação
SELECT [Id] AS [Identificador], [Nome] FROM [Curso] 
SELECT COUNT([Id]) AS [Total] FROM [Categoria]

-- JUNÇÃO DE TABELAS (JOIN)
-- Muito dificilmente iremos precisar de dados que estão em uma única tabela. Em nosso exemplo temos os cursos em uma tabela e as suas
-- respectivas categorias em outra. Para conseguir juntar esses dados usamos os JOINS. Existem vários tipos deles, sendo o mais famoso
-- o INNER JOIN. Os demais tipos são: OUTER JOIN, LEFT JOIN e RIGHT JOIN.

-- INNER JOIN (INTERSECÇÃO) -> quero buscar todos os cursos que também estejam nas categorias (deve haver correspondência). Se houver algum curso que não tem
-- categoria cadastrada, ele não será mostrado. A relação geralmente é sempre feita via chave estrangeira/chave primária, mas nada impede de
-- juntar por outros campos. 
SELECT 
[Curso].[Id],
[Curso].[Nome], 
[Curso].[CategoriaId],
[Categoria].[Nome]
FROM [Curso]
INNER JOIN [Categoria]
ON [Curso].[CategoriaId] = [Categoria].[Id]

-- LEFT JOIN -> pega todos os itens da primeira tabela, ou seja, a que está logo após o FROM. 
-- Permite trazer, por exemplo todos os cursos independente de ter ou não categoria associada. 
-- A categoria, caso não exista será apresentada como null. Isso aqui não irá acontecer, pois só conseguirei cadastrar curso se houver 
-- uma categoria cadastrada (chave estrangeira). 
SELECT
[Curso].[Id],
[Curso].[Nome], 
[Curso].[CategoriaId],
[Categoria].[Nome]
FROM [Curso]
LEFT JOIN [Categoria]
ON [Curso].[CategoriaId] = [Categoria].[Id]

-- RIGHT JOIN -> é o processo oposto do LEFT JOIN. 
-- irá trazer todos os dados da segunda tabela, independente de haver ou não correspondência primeira.
-- no nosso exemplo irá trazer todas as categorias, independente de haver ou não cursos associados.
-- se não houvesse algum curso, o mesmo seria apresentado como null.
-- foi cadastrado uma nova categoria que não possui curso correspondente. veja que os dados do curso apareceram como NULL
INSERT INTO [Categoria]([Nome])VALUES('Mobile')

SELECT
[Curso].[Id],
[Curso].[Nome], 
[Curso].[CategoriaId],
[Categoria].[Nome]
FROM
[Curso]
RIGHT JOIN [Categoria] 
ON [Curso].[CategoriaId] = [Categoria].[Id]


-- FULL JOIN / FULL OUTER JOIN -> irá combinar o LEFT e o RIGHT JOIN
-- irá trazer todos os cursos e todas as categorias. Dessa forma: 
-- cursos sem categorias serão listados; e categorias sem cursos também serão listadas.  
SELECT
[Curso].[Id],
[Curso].[Nome], 
[Curso].[CategoriaId],
[Categoria].[Nome]
FROM
[Curso]
FULL OUTER JOIN [Categoria] 
ON [Curso].[CategoriaId] = [Categoria].[Id]

-- UNION: permite juntar duas queries (consultas). Enquanto nos JOINS estamos juntando informações relacionadas
-- no UNION elas não necessariamente estão. No entanto, os campos das consultas devem ter dados similares, ou seja, 
-- conter o mesmo tipo de dado. Se ao invés de usar UNION colocarmos UNION ALL é como se estivesse executando um DISTINCT
-- e pagando somente os valores diferentes
SELECT
[Id], 
[Nome]
FROM [Curso]
UNION 
SELECT
[Id],
[Nome]
FROM [Categoria]


-- GROUP BY: sempre que houver a necessidade de agrupar elementos devemos usar o GROUP BY. 
-- ele é usado sempre com uma função de agregação, como por exemplo, o COUNT. 
-- todas as colunas que estiverem sendo trazidas no SELECT devem estar contidas no GROUP BY.
SELECT
[CategoriaId] AS Categoria,
COUNT([CategoriaId]) AS QtdCursos
FROM [Curso]
GROUP BY [CategoriaId]
ORDER BY [CategoriaId]

SELECT
[Curso].[Nome],
[Categoria].[Nome],
COUNT([Curso].[Id]) AS QuantidadeCursos
FROM [Curso]
INNER JOIN [Categoria]
ON [Curso].[CategoriaId] = [Categoria].[Id]
GROUP BY [Curso].[Nome],[Categoria].[Nome]

-- HAVING: trata-se de uma condicional para quando estamos trabalhando com dados agrupados
-- É usado em conjunto com o GROUP BY, ou seja, ao invés de usar WHERE usa-se o HAVING 
-- O seu uso permite filtrar o agrupameto da forma desejada. 
SELECT
[Categoria].[Nome],
COUNT([Curso].[Id]) as QtdCursos
FROM [Curso]
RIGHT JOIN [Categoria]
ON [Curso].[CategoriaId] = [Categoria].[Id]
GROUP BY [Categoria].[Nome]
HAVING COUNT([Curso].[Id]) = 0

SELECT
[Categoria].[Nome],
COUNT([Curso].[Id]) as QtdCursos
FROM [Curso]
RIGHT JOIN [Categoria]
ON [Curso].[CategoriaId] = [Categoria].[Id]
GROUP BY [Categoria].[Nome]
HAVING COUNT([Curso].[Id]) >= 1
ORDER BY COUNT([Curso].[Id]) 

-- VIEWS: muitas vezes as nossas queries ficam grandes e precisam ser executadas com frequência.
-- para facilitar a nossa vida existem as VIEWS. É uma "foto" de um SELECT que nós temos (consulta). 
-- o interessante é que podemos fazer um select em cima de uma view criada posteriormente, comportando-se como uma tabela.
-- Ao invés de usar o CREATE VIEW podemos usar diretamente o CREATE OR ALTER VIEW, pois assim se existir irá sobrescrever, caso contrário criará
-- o comando ORDER BY é inválido em VIEWS.

CREATE OR ALTER VIEW vwCategoriasSemCursosCadastrados AS
SELECT
[Categoria].[Nome],
COUNT([Curso].[Id]) as QtdCursos
FROM [Curso]
RIGHT JOIN [Categoria]
ON [Curso].[CategoriaId] = [Categoria].[Id]
GROUP BY [Categoria].[Nome]
HAVING COUNT([Curso].[Id]) = 0

SELECT * FROM vwCategoriasSemCursosCadastrados

SELECT * FROM vwCategoriasSemCursosCadastrados WHERE [Nome] = 'Mobile'


-- STORED PROCEDURES: são procedimentos armazenados em outras palavras pedaços de código que são salvos e executados posteriormente.
-- Dentro de uma SP podemos rodar qualquer uma das seguintes operações: CREATE, READ, UPDATE e DELETE. Inclusive combinar todos eles.
-- Podemos ter também o uso do SELECT. Também não é interessante deixar regras de negócio em SP. O bacana é ter isso a nível de aplicação.
-- Assim como na VIEW, uma STORED PROCEDURE pode ser criada usando: CREATE OR ALTER PROCEDURE <nome_procedimento>.
CREATE OR ALTER PROCEDURE spListaCursos AS
    SELECT TOP 10 * FROM [Curso]

EXEC [spListaCursos] 

DROP PROCEDURE [spListaCursos]


-- Uma SP também pode ser entendida como um SCRIPT com fluxo de execução.
-- Assim conseguimos usar dentro dela variáveis e parâmetros, tornando a lógica mais interessante.
-- Abaixo vemos um exemplo de como declarar variáveis e atribuir valores a ela.
DECLARE @CategoryId INT
SET @CategoryId = (SELECT [Id] FROM Categoria WHERE [Nome] = 'Frontend')
SELECT * FROM [Curso] WHERE [CategoriaId] = @CategoryId

-- Por fim uma SP que recebe parâmetros e aplica uma lógica em cima dos valores recebidos
-- Veja que o parâmetro foi inicializado, tornando ele opcional nesse caso
-- Posso ter quando parâmetros for necessário, basta separá-los por vírgula 

CREATE OR ALTER PROCEDURE [spListaCursosPorCategoria] 
    @Categoria NVARCHAR(50) = 'Backend'
AS
    DECLARE @IdCategoria INT
    SET @IdCategoria = (SELECT [Id] FROM [Categoria] WHERE [Nome] = @Categoria)
    SELECT * FROM [Curso] WHERE CategoriaId = @IdCategoria

EXEC [spListaCursosPorCategoria] 'Frontend'





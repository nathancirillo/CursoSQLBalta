USE [master];

CREATE DATABASE [Balta];

-- UNIQUEIDENTIFIER: possui prós e contras. Usa muito mais espaço do que um INT no banco, pois é uma cadeira de caracters. A consulta também 
-- é mais complexa do que  a busca por inteiro (identity).  
-- O ponto negativo do inteiro em relação ao GUID é a sua previsibilidade. Em uma URL, por exemplo, se existir o produto/1, certamente haverá
-- o produto/2, o produto/3, etc. 
-- O GUID é mais fácil de ser gerado: pode ser feito tanto pelo C# como pelo SQL Server. 
CREATE TABLE [Student]
(
    [Id] UNIQUEIDENTIFIER NOT NULL,
    [Name] NVARCHAR(120) NOT NULL,
    [Email] NVARCHAR(180) NOT NULL,
    [Document] NVARCHAR(20),
    [Phone] NVARCHAR(20),
    [Birthdate] DATETIME,
    [CreateDate] DATETIME NOT NULL DEFAULT(GETDATE()),
    CONSTRAINT [PK_Student] PRIMARY KEY ([Id])
);

-- NEWID(): permite gerar um GUID no SQL SERVER. O seu retorno pode ser usado dentro de uma SP, por exemplo. 
SELECT NEWID() AS MyGuid;


-- GETDATE() VS GETUTCDATE(): o GETDATE() sempre irá retornar a hora do servidor local, ou seja, se existiver no EUA será -3 hrs em relação
-- ao Brasil. Agora usando o GETUTCDATE() trata-se de uma data universal. 
SELECT GETDATE() AS DataHoraLocal, GETUTCDATE() AS DataHoraUniversal



-- Na tabela Author o que chama atenção é o TINYINT do campo Type. Ele é um tipo diferente do inteiro. O inteiro vai de -32K até 32K, já
-- o TINYINT vai de 0 a 255. Como ele será mapeado através de um ENUM no C#, então não é necessário ter um inteiro aqui. 
CREATE TABLE [Author]
(
    [Id] UNIQUEIDENTIFIER NOT NULL,
    [Name] NVARCHAR(80) NOT NULL,
    [Title] NVARCHAR(80) NOT NULL, 
    [Image] NVARCHAR(1024) NOT NULL,
    [Bio] NVARCHAR(2000) NOT NULL,
    [Url] NVARCHAR(450) NULL,
    [Email] NVARCHAR(160) NOT NULL,
    [Type] TINYINT NOT NULL,
    CONSTRAINT [PK_Author] PRIMARY KEY ([Id])
)


CREATE TABLE [Carrer]
(
    [Id] UNIQUEIDENTIFIER NOT NULL,
    [Title] NVARCHAR(160) NOT NULL,
    [Summary] NVARCHAR(2000) NOT NULL,
    [Url] NVARCHAR(1024) NOT NULL,
    [DurationInMinutes] INT NOT NULL,
    [Active] BIT NOT NULL,
    [Featured] BIT NOT NULL,
    [Tags] NVARCHAR(160) NOT NULL,
    CONSTRAINT [PK_Carrer] PRIMARY KEY ([Id])
)


-- Na tabela de categoria o único ponto que vemos de diferente é o tipo TEXT. Ele é usado quando o valor a ser armazenado é bem longo,
-- permite ter HTML dentro dele também. 
CREATE TABLE [Category]
(
    [Id] UNIQUEIDENTIFIER NOT NULL,
    [Title] NVARCHAR(160) NOT NULL,
    [Url] NVARCHAR(1024) NOT NULL,
    [Summary] NVARCHAR(2000) NOT NULL,
    [Order] INT NOT NULL,
    [Description] TEXT NOT NULL,
    [Featured] BIT NOT NULL,
    CONSTRAINT [PK_Category] PRIMARY KEY ([Id])
)


-- Na tabela de curso o ponto a ser destacado está nas FOREIGN KEYs. Elas possui um item a mais do que já foi visto: ON DELETE NO ACTION.
-- Isso significa que ao excluir um curso, não desejamos excluir nem o autor e nem a categoria relacionada a ele. Esse já é o comportamento padrão existente. 
-- Se quisessmos que na exclusão do curso também fosse excluído o autor e/ou a categoria deveríamos usar: ON DELETE CASCADE.
CREATE TABLE [Course]
(
    [Id] UNIQUEIDENTIFIER NOT NULL,
    [Tag] NVARCHAR(20) NOT NULL,
    [Title] NVARCHAR(160) NOT NULL,
    [Summary] NVARCHAR(2000) NOT NULL,
    [Url] NVARCHAR(1024) NOT NULL,
    [Level] TINYINT NOT NULL,
    [DurationInMinutes] INT NOT NULL,
    [CreateDate] DATETIME NOT NULL,
    [LastUpdateDate] DATETIME NOT NULL,
    [Active] BIT NOT NULL,
    [Free] BIT NOT NULL,
    [Featured] BIT NOT NULL,
    [AuthorId] UNIQUEIDENTIFIER NOT NULL,
    [CategoryId] UNIQUEIDENTIFIER NOT NULL,
    [Tags] NVARCHAR(160) NOT NULL,
    CONSTRAINT [PK_Course] PRIMARY KEY ([Id]),
    CONSTRAINT [FK_Course_Author] FOREIGN KEY ([AuthorId]) REFERENCES [Author]([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_Course_Category] FOREIGN KEY ([CategoryId]) REFERENCES [Category]([Id]) ON DELETE NO ACTION
)



CREATE TABLE [CarrerItem]
(   
    [CarrerId] UNIQUEIDENTIFIER NOT NULL,
    [CourseId] UNIQUEIDENTIFIER NOT NULL,    
    [Title] NVARCHAR(160) NOT NULL,
    [Description] TEXT NOT NULL,
    [Order] TINYINT NOT NULL,   
    CONSTRAINT [PK_CarrerItem] PRIMARY KEY ([CourseId], [CarrerId]),
    CONSTRAINT [FK_CarrerItem_Course] FOREIGN KEY ([CourseId]) REFERENCES [Course]([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_CarrerItem_Carrer] FOREIGN KEY ([CarrerId]) REFERENCES [Carrer]([Id]) ON DELETE NO ACTION
)

CREATE TABLE [StudentCourse]
(
    [CourseId] UNIQUEIDENTIFIER NOT NULL,
    [StudentId] UNIQUEIDENTIFIER NOT NULL,    
    [Progress] TINYINT NOT NULL,
    [Favorite] BIT NOT NULL,   
    [StartDate] DATETIME NOT NULL,
    [LastUpdateDate] DATETIME NULL,
    CONSTRAINT [PK_StudentCourse] PRIMARY KEY ([CourseId], [StudentId]),
    CONSTRAINT [FK_StudentCourse_Course] FOREIGN KEY ([CourseId]) REFERENCES [Course]([Id]) ON DELETE NO ACTION,
    CONSTRAINT [FK_StudentCourse_Student] FOREIGN KEY ([StudentId]) REFERENCES [Student]([Id]) ON DELETE NO ACTION    
)


-- À PARTIR DESSE PONTO A BASE BALTA FOI DROPADA E IMPORTADA UMA JÁ POPULADA PARA A REALIZAÇÃO DAS CONSULTAS

-- Busca os cursos que estão ativos trazendo os mais recentes primeiro
-- A junção é feita pelo INNER JOIN tanto na tabela de categoria como na tabela de autores, pois sabemos que não existem cursos sem categoria e sem autor, ou seja, sempre haverá correspondência
-- Ao fazer a junção é interessante na clásula ON sempre apontar primeiro a tabela de referência, ou seja, a que vem do FROM. No nosso caso Course.
-- Para facilitar vamos criar uma VIEW, pois assim não precisamos ficar digitando sempre essa QUERY. 
-- Lembrando que na VIEW não podemos ter o ORDER BY, porém podemos aplicar em cima do seu resultado.

CREATE OR ALTER VIEW vwCourses AS
SELECT 
    [Course].[Id],
    [Course].[Tag],
    [Course].[Title],
    [Course].[Url],
    [Course].[Summary],
    [Course].[CreateDate],
    [Category].[Title] AS [Category],
    [Author].[Name] AS [Author]
FROM 
    [Course]
    INNER JOIN [Category] ON [Course].[CategoryId] = [Category].[Id]
    INNER JOIN [Author] ON [Course].[AuthorId] = [Author].[Id]
WHERE 
    [Active] = 1


-- Usando a VIEW criada
SELECT * FROM vwCourses ORDER BY [CreateDate] DESC



-- Buscando as carreiras e a quantidade de cursos por carreira que está contida na tabela CareerItem
-- Essa é a forma menos recomendada. Veja que está sendo usado um SELECT na coluna e isso é ruim
-- Para cada registro ele vai ter que fazer uma consulta para saber quantos itens tem. Isso perde performance
-- Esse tipo de estrutura é chamada de SUBSELECT: quando usamos uma consulta dentro de outra
SELECT 
    [Id],
    [Title],
    [Url],
    (SELECT COUNT([CareerId]) FROM [CareerItem] WHERE [CareerId] = [Id]) AS [Courses]
FROM 
   [Career]


-- Veja que dessa forma é muito melhor. Além de ficar mais bem organizado, a sua execução é mais performática 
-- Iremos criar também uma VIEW para que possamos sempre usar quando necessário 
CREATE OR ALTER VIEW vwCareers AS 
SELECT DISTINCT
    [Career].[Id],
    [Career].[Title],
    [Career].[Url],
    COUNT([CareerItem].[CareerId]) AS Courses
FROM
    [Career]
    INNER JOIN [CareerItem] ON [Career].[Id] = [CareerItem].[CareerId]
GROUP BY 
    [Career].[Id], 
    [Career].[Title], 
    [Career].[Url]

-- usando a VIEW criada anteriormente
SELECT * FROM vwCareers    


-- Agora iremos inserir alguns dados nas tabelas: Student e StudentCourse
-- Existem duas formas de fazer o INSERT: informados as colunas ou omitindo-as
-- A vantagem de deixar explicito é que evita trocar os valores na hora da inserção dos dados

SELECT * FROM [Student]
SELECT * FROM [StudentCourse]
SELECT * FROM [Course]


-- Script criado para inserir registros nas tabelas: Student e StudentCourse
-- A ideia é gerar sempre um novo GUID (UNIQUEIDENTIFIER) para o ID do aluno e esse ser reaproveitado em ambas as tabelas
-- Depois é sorteado um curso aleatório a fim de pegar o Id desse curso e então converte-lo para um UNIQUEIDENTIFIER. Também é aproveitado em ambas as tabelas
DECLARE @StudentId UNIQUEIDENTIFIER = NEWID()
DECLARE @CourseId UNIQUEIDENTIFIER = CAST((SELECT TOP 1 [Id] FROM [Course] ORDER BY NEWID()) AS UNIQUEIDENTIFIER)
INSERT INTO
    [Student]
VALUES
(
    @StudentId,
    'Nathan Cirillo',
    'hello@cirillo.com',
    '12345678',
    '(11)996172112',
    CAST('20/09/1990' AS DATETIME) ,
    GETDATE()
);
GO
INSERT INTO
    [StudentCourse]
VALUES
(
    @CourseId,
    @StudentId,
    10,
    0,
    '20/03/2014',
    GETDATE()
);


-- Por fim o INNER JOIN serve para conferir se a inserção ocorreu como o esperado, havendo correspondência entre as tabelas
SELECT
    [Student].[Name],
    [StudentCourse].[Progress],
    [Course].[Title]
FROM
    [Student]
INNER JOIN [StudentCourse] ON [Student].[Id] = [StudentCourse].[StudentId]
INNER JOIN [Course] ON [StudentCourse].[CourseId] = [Course].[Id]

-- Trabalhando a consulta apresentada acima para que faça a filtragem de dados caso houvesse mais alunos
-- Para isso será usado uma variável com o Id desse aluno
-- Estou trazendo os dados dos cursos iniciados, mas não concluídos do aluno especificado no Id
DECLARE @StudentId UNIQUEIDENTIFIER = '8ec45c28-8a5d-4138-ace0-7108c03ebe25'
SELECT
    [Student].[Name],
    [Course].[Title],
    [StudentCourse].[Progress]
FROM 
    [StudentCourse]
    INNER JOIN [Student] ON [StudentCourse].[StudentId] = [Student].[Id]
    INNER JOIN [Course] ON [StudentCourse].[CourseId] = [Course].[Id]
WHERE
    [StudentCourse].[StudentId] = @StudentId
    AND
    [StudentCourse].[Progress] < 100
    AND
    [StudentCourse].[Progress] > 0
ORDER BY 
    [StudentCourse].[LastUpdateDate] DESC


-- Na query abaixo o objetivo é trazer todos os dados da tabela Course e se houver dados em StudentCourse e em Student também trazer
-- Nesse caso está sendo usado o LEFT JOIN para isso. Veja a praticidade:
SELECT
    [Course].[Title],
    [Student].[Name],
    [StudentCourse].[Progress],
    [StudentCourse].[LastUpdateDate]
FROM
    [Course]
    LEFT JOIN [StudentCourse] ON [Course].[Id] = [StudentCourse].[CourseId]
    LEFT JOIN [Student] ON [StudentCourse].[StudentId] = [Student].[Id]


-- Na penúltima consulta apresentada veja que estamos usando o Id do estudante como sendo uma variável
-- Eu não posso dessa forma criar uma VIEW usando essa consulta, a não ser que o Id seja fixo e traga sempre o mesmo aluno
-- Esse é um caso interessante onde podemos usar uma STORED PROCEDURE que recebe o Id do aluno via parâmetro 
CREATE OR ALTER PROCEDURE spBuscaDadosDoCursoDoAluno
(
    @StudentId UNIQUEIDENTIFIER 
)
AS
SELECT
    [Student].[Name],
    [Course].[Title],
    [StudentCourse].[Progress]
FROM 
    [StudentCourse]
    INNER JOIN [Student] ON [StudentCourse].[StudentId] = [Student].[Id]
    INNER JOIN [Course] ON [StudentCourse].[CourseId] = [Course].[Id]
WHERE
    [StudentCourse].[StudentId] = @StudentId
    AND
    [StudentCourse].[Progress] < 100
    AND
    [StudentCourse].[Progress] > 0
ORDER BY 
    [StudentCourse].[LastUpdateDate] DESC

--Executando a SP criada anteriormente
EXEC spBuscaDadosDoCursoDoAluno '8ec45c28-8a5d-4138-ace0-7108c03ebe25'     

-- Para finalizar irei criar um SP que será responsável por excluir a conta do aluno
-- Veja que a ordem de exclusão na SP é feito primeiro na StudentCourse para depois excluir em Student
-- O interessante de trabalhar com transações é que se algo acontecer de errado, automaticamente será dado um ROLLBACK na transação
-- Para que esse comportamento da transaction aconteça deverá estar como COMMIT, pois do jeit que está sempre está desfazendo a exclusão
CREATE OR ALTER PROCEDURE spExcluiContaAluno
(
    @StudentId UNIQUEIDENTIFIER
)
AS
    DELETE FROM [StudentCourse] WHERE [StudentCourse].StudentId = @StudentId
    DELETE FROM [Student] WHERE [Student].[Id] = @StudentId
   

-- Excluindo a conta do aluno via SP
BEGIN TRAN
    EXEC spExcluiContaAluno '8ec45c28-8a5d-4138-ace0-7108c03ebe25'  
ROLLBACK
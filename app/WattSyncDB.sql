/* quem estiver lendo no Workbench, recomendo tirar a barra lateral direita para melhor leitura. */

CREATE SCHEMA historic /*(Nome do bluetooth do esp32, assim da para conectar mais de um dispositivo sem mesclar os bancos de dados)*/ DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci ;
use historic;

/*Recebe as informações do dispositivo e adicona na tabela até possuir 60 registros para formar 1 minuto, tira a média de todos os valores (para descobrir o valor médio de cada minuto), 
envia para a tabela minutes, em seguida apaga todos os dados e da reset na chave primária*/
  
CREATE TABLE seconds ( 
  sec_id int NOT NULL auto_increment,
  sec_time time, /* caso não tenha recebido valores em algum segundo, marcar os campos com 0 (exceto o "value_kw", esse é obtido do prórpio aplicativo) */
  sec_miliampers float,
  sec_volts float,
  sec_value_kw float,
  primary key(sec_id)
);

/*recebe a média das colunas "sec_miliampers", "sec_volts" e "sec_value_kw" da tabela "seconds" e adiciona nessa tabela até ter 60 registros para formar 1 hora,
tira a média de todos os valores (para descobrir os valores médios de cada hora),
envia para a tabela hours, em seguida apaga todos os dados e da reset na chave primária*/

CREATE TABLE minutes (
  min_id int NOT NULL auto_increment,
  min_time time,  /* caso não tenha recebido valores em algum minuto, marcar os campos com 0 (exceto o "value_kw", esse é obtido do prórpio aplicativo) */
  min_miliampers float,
  min_volts float,
  min_value_kw float,
  primary key(min_id)
);

/*recebe a média das colunas "min_miliampers", "min_volts" e "min_value_kw" da tabela "minutes" e adiciona nessa tabela até ter 24 registros para formar 1 dia,
agora é diferente, tira a media do "hour_volts" e "hour_value_kw" (para descobrir os valores médios de cada dia), já a coluna "hours_miliampers"
deve ser seus registros somados, depois envia para a tabela "days" e em seguida apaga todos os dados e da reset na chave primária*/

CREATE TABLE hours (
  hour_id int NOT NULL auto_increment,
  hour_datetime datetime,  /* caso não tenha recebido valores em alguma hora, marcar os campos com 0 (exceto o "value_kw", esse é obtido do prórpio aplicativo) */
  hour_miliampers float,
  hour_volts float,
  hour_value_kw float,
  primary key(hour_id)
);
  
/*recebe os mesmos dados da tabela "hours", a diferença que aqui ela não é apagada totalmente, quando chega no 25° registro o 1° registro é apagado, assim sucessivamente*/

CREATE TABLE last_24_hours (
  lst_hour_id int NOT NULL auto_increment,
  lst_hour_datetime datetime,  /* caso não tenha recebido valores em alguma hora, marcar os campos com 0 (exceto o "value_kw", esse é obtido do prórpio aplicativo) */
  lst_hour_miliampers float,
  lst_hour_volts float,
  lst_hour_value_kw float,
  primary key(lst_hour_id)
);

/*recebe a média das colunas "hour_volts" e "hour_value_kw" junto da soma da coluna "hour_miliampers" dividida por 1000 para a conversão de grandezas da tabela "hours" e
adiciona nessa tabela até ter 31 registros para formar 1 mês, tira a media do "day_volts" e "day_value_kw" (para descobrir os valores médios de cada dia), e soma a coluna "day_ampers",
depois envia para a tabela "last_12_months" e em seguida apaga todos os dados e da reset na chave primária*/

CREATE TABLE days (
  day_id int NOT NULL auto_increment,
  day_date date,  /* caso não tenha recebido valores em algum dia, marcar os campos com 0 (exceto o "value_kw", esse é obtido do prórpio aplicativo) */
  day_ampers float,
  day_volts float,
  day_value_kw float,
  primary key(day_id)
);

/*recebe os mesmos dados da tabela "days", a diferença que aqui ela não é apagada totalmente, quando chega no 30° registro o 1° registro é apagado, assim sucessivamente*/

CREATE TABLE last_30_days (
  lst_day_id int NOT NULL auto_increment,
  lst_day_date date,  /* caso não tenha recebido valores em algum dia, marcar os campos com 0 (exceto o "value_kw", esse é obtido do prórpio aplicativo) */
  lst_day_ampers float,
  lst_day_volts float,
  lst_day_value_kw float,
  primary key(lst_day_id)
);

/*recebe a média das colunas "day_volts" e "days_value_kw" junto da soma da coluna "day_ampers" da tabela "days", esse tabela não é apagada totalmente, 
quando chega no 13° registro o 1° registro é apagado, assim sucessivamente */

CREATE TABLE last_12_months (
  lst_mnt_id int NOT NULL auto_increment,
  lst_mnt_date date,  /* caso não tenha recebido valores em algum mês, marcar os campos com 0 (exceto o "value_kw", esse é obtido do prórpio aplicativo) */
  lst_mnt_ampers float,
  lst_mnt_volts float,
  lst_mnt_value_kw float,
  primary key(lst_mnt_id)
);
  
/* Vocês devem achar alguma maneira de utilizar as informações de tempo (as colunas time, datetime e time, podem alterar o seu tipo a vontade, mas acho que do jeito que estão é a opção mais otimizada)
e caso tenha algum momento onde o apilcativo não recebeu o valor enviado pelo dispositivo, marcar como 0, 
por exemplo, se ficou 1 mês sem receber regristro, marcar como 0 diretamente na tabela "last_12_months", esse esquema em todas as tabelas.

Todas as tabelas com o prefixo "last" são tabelas contínuas, como se fosse subir em uma escada rolante, para o primeiro degrau embaixo aparecer o último lá em cima deve sumir.
Ainda sobre as tabelas "last", o nome é auto-explicativo, servem apenas e exclusivamente para mostrar os registros quando é selecionado a opção "Últimos (as) XX YY", sendo X a quantidade e Y a escala de tempo, 
por exemplo "Últimas 24 horas" utilizando a tabela "last_24_hours". A tabela de meses serve tanto para a opção "Últimos 6 meses" quanto para "Últimos 12 meses". 

A data pode ser no padrão que quiserem, já a hora recomendo pegar baseado no país, mas se não quiserem só colocar em GMT-3 que é sucesso.

Por último, mesmo supondo que não haja necessidade de informá-los disso, o nome de cada coluna ou tabela pode ser alterado a bel-prazer, fiz dessa maneira apenas para facilitar o entendimento. 
*/ 
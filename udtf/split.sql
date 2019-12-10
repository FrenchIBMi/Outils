-- réglage du schema/path :
set current schema = nb ;
set path = nb ; 

-- Découpage d'une données en ligne
create or replace function split ( datas varchar(32000) , len int default 100 )
returns table ( line varchar(1024) )
language sql 
begin
  declare cpt int default 1 ;
  declare pos int default 1 ;
  declare line char(1024) ;

  -- Contrôles
  if length( datas) = 0 or len <= 0 then
    return ;
  end if ;
  -- boucle de découpage
  while length(datas) > len * cpt do 
    pipe( substr( datas, pos, len ) ) ;
    set cpt = cpt + 1 ;
    set pos = pos + len ; 
  end while ;
  -- reliquat ?
  if length(datas) <= len * cpt then
    set line = substr( datas, pos ) ;
    pipe( left( line, len ) ) ;
  end if ;
  return ;
end ;


-- exemples d'appels
select line, length(line) from table( split('abcdef', 1)) ;
select line, length(line) from table( split('abcdef', 2)) ;
select line, length(line) from table( split('abcdefg', 2)) ;
select line, length(line) from table( split('         1         2         3         4         5         6         7', 10)) ;
select line, length(line) from table( split('         1         2         3         4         5         6         7', 11)) ;
select line, length(line) from table( split('         1         2         3         4         5         6         7', 100)) ;
select line, length(line) from table( split('         1         2         3         4         5         6         7', 0)) ;
select line, length(line) from table( split('', 0)) ;
select line, length(line) from table( split('         1         2         3         4         5         6         7')) ;
select line, length(line) from table( split('         1         2         3         4         5         6         7', default)) ;
select line, length(line) from table( split(datas =>'         1         2         3         4         5         6         7', len => default)) ;
select line, length(line) from table( split(len => 12, datas =>'         1         2         3         4         5         6         7')) ;
select line, length(line) from table( split(datas =>'         1         2         3         4         5         6         7')) ;
select line, length(line) from table( split('', 10)) ;

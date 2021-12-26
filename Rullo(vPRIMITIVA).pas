program Rullo;
  uses CRT;
  const
    MIN = 1; MAX = 9;
  type
    Tcelda = record
      visible : integer;  {numeros random en tablas}
      sumable : boolean;  {pos generadas que hay que selec. para ganar}
      activado : boolean; {posiciones selecionadas por el jugador}
    end;
    Ttabla = array[MIN..MAX, MIN..MAX] of Tcelda;
  var celda: Tcelda;
      tabla: Ttabla;
  
  PROCEDURE Ayuda;
BEGIN
  WRITELN;
  WRITELN(' AYUDA ');
  WRITELN;
  WRITELN('El juego consiste en que la suma de los numeros de cada fila -numeros de la ultima columna de la derecha de la tabla- o columna -numeros de la primera fila, encima de la tabla-  debe ser igual al numero del sumatorio de filas o de columnas esperado.');
  WRITELN('usted debe seleccionar un numero para excluirlo de la suma hasta conseguir que la suma de los restantes numeros sean iguales a los del sumatorio.');
  WRITELN;
  WRITELN('Para seleccionar un numero, debe indicar el numero de fila y columna de la cifra que quiere activar o desactivar.');
  WRITELN;
  WRITE('Se  desactivara una cifra poniendose un 0 en la posicion indicada y se activara poniendose el valor original. ');
  WRITELN('Debe tener en cuenta que inicialennte todas las cifras estan activadas.');
  WRITELN;
  WRITE('Por ultimo, para poder abandonar una partida el tablero se debe haber inicializado; en ese caso podra seleccionar la opcion de salir');
  WRITELN;
  WRITELN;
  WRITELN('TECLEE CUALQUIER TECLA PARA VOLVER A INICIO');
  READLN;
  CLRSCR;
END;
      
  FUNCTION ElegirPartida:char;  {OPCION 2 ELEGIR PARTIDA}
    VAR c: char;
    BEGIN
      REPEAT
        WRITELN('     5x5  6x6  7x7');
        WRITELN(' 1-9  A    B    C');
        WRITELN('1-19  D    E    F');
        WRITE('Escriba el tipo de partida que quiere jugar ');c:= readkey;
        c:=UPCASE(c); CLRSCR;
      UNTIL(c='A') or (c='B') or (c='C') or (c='D') or (c='E') or (c='F') or (c=chr(27));
      ElegirPartida:= c;
    END;
    
  {Muestra el menu}
  FUNCTION Menu:char;
    BEGIN
      WRITELN(' MENU ');
      WRITELN('1.Obtener ayuda');
      WRITELN('2.Seleccionar la dimension');
      WRITELN('3.Leer ranking');
      WRITELN('4.Salir');
      REPEAT
        Menu:= readkey;
      UNTIL(Menu>=chr(48)) and (Menu<=chr(52));
      CLRSCR;
    END;
    
  PROCEDURE GenNumRND(var t:Ttabla;dim,rango:integer); {GEN NUM RANDOM}
    var i,e:integer;
    begin
      for i:=1 to MAX do begin
        for e:=1 to MAX do begin
          if (i > dim) or (e > dim) then begin
            t[i][e].visible:= 0;
            t[i][e].sumable:= false;
            t[i][e].activado:= false;
            end
          else
            begin
            t[i][e].visible:= RANDOM(rango)+1;
            t[i][e].sumable:=true;
            t[i][e].activado:= true;
            end;
        end;
      end;
    end;
  
  PROCEDURE GenPosGanadora(var t:Ttabla;dim:integer);
    var i,e,cont: integer;
    FUNCTION VerFilas(t:Ttabla;x,y:integer):integer; {Cuenta los FALSE}
      BEGIN
        if (y=MAX) then begin
          if (t[x][y].sumable=false) then
            VerFilas:=1
          else
            VerFilas:=0;  
          end
        else
          if (t[x][y].sumable=false) then
            VerFilas:=1+VerFilas(t,x,y+1)
          else
            VerFilas:=0+VerFilas(t,x,y+1);
      END;
    FUNCTION VerColumnas(t:Ttabla;x,y:integer):integer; {Cuenta los FALSE}
      BEGIN
        if (x=MAX) then begin
          if (t[x][y].sumable=false) then
            VerColumnas:=1
          else
            VerColumnas:=0;  
          end
        else
          if (t[x][y].sumable=false) then
            VerColumnas:=1+VerColumnas(t,x+1,y)
          else
            VerColumnas:=0+VerColumnas(t,x+1,y);
      END;
    BEGIN
      cont:=0;
      REPEAT
        REPEAT
          i:= RANDOM(dim)+1; e:= RANDOM(dim)+1;
          if (t[i][e].sumable=true) AND ((VerFilas(t,i,1)<dim) OR (VerColumnas(t,1,e)<dim) OR (VerFilas(t,i,1)=0) OR (VerColumnas(t,1,e)=0)) then
            t[i][e].sumable:=false;
        UNTIL(t[i][e].sumable=false);
        cont:=succ(cont);
      UNTIL(cont=dim*2);
    END;
  
  PROCEDURE ActivarDes(var t:Ttabla;x,y:integer); {Cambios act/desact del jugador}
    begin
      if (t[x][y].activado=false) then
        t[x][y].activado:=true
      else
        t[x][y].activado:=false;
    end;
  
  PROCEDURE Rellenar8y9(var t:Ttabla;dim:integer);
    var num:integer;
    FUNCTION SumFila(t:Ttabla;i,e,dim:integer):integer;
      BEGIN
        if (e=dim) then begin
          if (t[i][e].activado=true) then
            SumFila:=t[i][e].visible
          else
            SumFila:=0;
          end
        else
          if (t[i][e].activado=true) then
            SumFila:= t[i][e].visible + SumFila(t,i,e+1,dim)
          else 
            SumFila:= 0 + SumFila(t,i,e+1,dim);
      END;
    FUNCTION SumColumna(t:Ttabla;i,e,dim:integer):integer;
      BEGIN
        if (i=dim) then begin
          if (t[i][e].activado=true) then
            SumColumna:=t[i][e].visible
          else 
            SumColumna:=0;
          end
        else
          if (t[i][e].activado=true) then
            SumColumna:= t[i][e].visible + SumColumna(t,i+1,e,dim)
          else
            SumColumna:= 0 + SumColumna(t,i+1,e,dim);
      END;
    FUNCTION SumFilaOBJ(t:Ttabla;i,e,dim:integer):integer;
      BEGIN
        if (e=dim) then begin
          if (t[i][e].sumable=true) then
            SumFilaOBJ:=t[i][e].visible
          else
            SumFilaOBJ:=0;
          end
        else
          if (t[i][e].sumable=true) then
            SumFilaOBJ:= t[i][e].visible + SumFilaOBJ(t,i,e+1,dim)
          else 
            SumFilaOBJ:= 0 + SumFilaOBJ(t,i,e+1,dim);
      END;
    FUNCTION SumColumnaOBJ(t:Ttabla;i,e,dim:integer):integer;
      BEGIN
        if (i=dim) then begin
          if (t[i][e].sumable=true) then
            SumColumnaOBJ:=t[i][e].visible
          else 
            SumColumnaOBJ:=0;
          end
        else
          if (t[i][e].sumable=true) then
            SumColumnaOBJ:= t[i][e].visible + SumColumnaOBJ(t,i+1,e,dim)
          else
            SumColumnaOBJ:= 0 + SumColumnaOBJ(t,i+1,e,dim);
      END;
    BEGIN
      num:=1;
      REPEAT
        t[num][MAX].visible:=SumFila(t,num,1,dim);
        t[MAX][num].visible:=SumColumna(t,1,num,dim);
        t[num][MAX-1].visible:=SumFilaOBJ(t,num,1,dim);
        t[MAX-1][num].visible:=SumColumnaOBJ(t,1,num,dim);
        num:=succ(num);
      UNTIL(num=MAX)
    END;
  
  PROCEDURE PrintTab(var t:Ttabla); {IMPRIME POR PANTALLA SOLO MAYOR QUE 0}
    var i,e: integer;
    begin
      for i:=1 to MAX do begin
        for e:=1 to MAX do begin
          if (t[i][e].activado=false) then
            TEXTCOLOR(lightred);
          if not(t[i][e].visible=0) then begin
            if (t[i][e].visible<10) then
              WRITE(' ',t[i][e].visible,'  ')
            else
              WRITE(t[i][e].visible,'  ');
          end;
          TEXTCOLOR(white);
        end;
        WRITELN;
      end;
      WRITELN('META (Fila y columna 8)');
      WRITELN('SUMA ACTIVADOS (Fila y columna 9)');
    end;
  
  FUNCTION Victoria(t:Ttabla;i,e,dim:integer):boolean; {Verifica si sumables = activados}
    BEGIN
      if (i=dim) and (e=dim) then
        Victoria:=t[i][e].sumable = t[i][e].activado
      else
        if (e=dim) then
          Victoria:= (t[i][e].sumable = t[i][e].activado) and Victoria(t,i+1,1,dim)
        else
          Victoria:= (t[i][e].sumable = t[i][e].activado) and Victoria(t,i,e+1,dim);
    END;
  
  PROCEDURE Juego(var t:Ttabla);
    VAR i,e,rango,dim: integer;
        opcionPartida:char;
        exit:boolean;
    BEGIN
      exit:=false;
      opcionPartida:=ElegirPartida;
      CASE opcionPartida OF
        'A','B','C': begin rango:= 9; dim:= ord(opcionPartida) - 60; end; 
        'D','E','F': begin rango:= 19; dim:= ord(opcionPartida) - 63; end;
      END;
      GenNumRND(t,dim,rango);
      GenPosGanadora(t,dim);
      Rellenar8y9(t,dim);
      REPEAT
        PrintTab(t);           //INICIO
        WRITELN('ESCRIBA LAS COORDENADAS (X,Y)');
        WRITELN('Para salir X e Y tienen que ser 0');
        READLN(i,e);
        if (i=0) or (e=0) then
          exit:=true;
        ActivarDes(t,i,e); 
        Rellenar8y9(t,dim);       //FINAL
        CLRSCR;
      UNTIL(Victoria(t,1,1,dim)=true) or (exit = true);
      //IF PUNTUACION (NUM MOVS MAYOR QUE LOS REGISTRADOS) PEDIR DATOS, NOMBRE
      
    END;
  
  PROCEDURE ExeGame(var t:Ttabla);
    begin
      REPEAT
        CLRSCR;
        CASE Menu of
          '1': Ayuda;
          '2': Juego(t);
          '3': BEGIN WRITELN('No habilitado, pulse cualquier tecla para salir'); READKEY; CLRSCR; END;
        END;
      UNTIL(Menu = '4');
      WRITELN('Gracias por jugar');
      WRITELN('Hasta pronto!');
    end;
begin
  TEXTCOLOR(white);
  RANDOMIZE;
  CLRSCR;
  ExeGame(tabla);
end.


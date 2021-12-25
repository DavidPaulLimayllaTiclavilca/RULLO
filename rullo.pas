program Rullo;
USES
   CRT;
CONST
  MIN = 1;
  MAX = 300;
TYPE
   TRuta = String[100];

   TLimite = MIN..MAX;

   TCelda = RECORD
     visible: integer;
     sumable: integer;
     activado: boolean;
   end;

   TPartida = RECORD
      nombreJugador: String[40];
      puntuacion: integer;
      tipo: char;
   end;

   TTabla = ARRAY[TLimite, TLimite] OF TCelda;

   TArrayPartidas = ARRAY[TLimite] OF TPartida;

   TFicheroPartidas = FILE OF TPartida;

VAR
  fich:TFicheroPartidas;

FUNCTION ElegirPartida:char;
    VAR c: char;
    BEGIN
      REPEAT
        WRITELN('     5x5  6x6  7x7');
        WRITELN(' 1-9  A    B    C');
        WRITELN('1-19  D    E    F');
        WRITE('Escriba el tipo de partida que quiere jugar ');c:= readkey;
        CLRSCR; c:=UPCASE(c);
      UNTIL(c='A') or (c='B') or (c='C') or (c='D') or (c='E') or (c='F');
      ElegirPartida:= c;
    END;
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

PROCEDURE ActualizarSumatorioFila(VAR tablaF: TTabla; i, aux ,dim: integer);
VAR
  j: integer;
BEGIN

    FOR j := MIN TO dim DO
      tablaF[i,j].sumable := aux;

end;

PROCEDURE ActualizarSumatorioColumna(VAR tablaC: TTabla; j, aux, dim: integer);
VAR
  i: integer;
BEGIN

    FOR i := MIN TO dim DO
      tablaC[i,j].sumable := aux;

end;

PROCEDURE ActualizarFila(VAR tablaF_Bis: TTabla; fila, dim: integer);
VAR
  j, aux, suma: integer;
BEGIN

  suma := 0;
  FOR j := MIN TO dim DO BEGIN
    IF(tablaF_Bis[fila,j].activado = TRUE) THEN BEGIN
        aux := tablaF_Bis[fila,j].visible;
        suma := suma + aux;
    end;
  end;
  ActualizarSumatorioFila(tablaF_Bis ,fila ,suma,dim);

end;

PROCEDURE ActualizarColumna(VAR tablaC_Bis: TTabla; columna, dim: integer);
VAR
  i, aux, suma: integer;
BEGIN

  suma := 0;
  FOR i := MIN TO dim DO BEGIN
    IF(tablaC_Bis[i, columna].activado = TRUE) THEN BEGIN
        aux := tablaC_Bis[i, columna].visible;
        suma := suma + aux;
    end;
  end;
  ActualizarSumatorioColumna(tablaC_Bis, columna, suma,dim);

end;

FUNCTION VerificarNCeldasFilaNula(tablaF: TTabla; numFila, dim: integer):integer;
//verifica si hay [dim-1]celdas de una filas vacias
VAR
  j, cont: integer;
BEGIN

  cont := 0;
  FOR j := MIN TO dim DO BEGIN
    IF(tablaF[numFila, j].activado = FALSE) THEN
      cont := cont + 1;
  end;

  VerificarNCeldasFilaNula := cont;

end;

FUNCTION VerificarNCeldasColumnaNula(tablaC: TTabla; numColumna, dim: integer):integer;
//verifica si hay [dim-1]celdas de una columnas vacias
VAR
  i, cont: integer;
BEGIN

  cont := 0;
  FOR i := MIN TO dim DO BEGIN
    IF(tablaC[i, numColumna].activado = FALSE) THEN
      cont := cont + 1;
  end;

  VerificarNCeldasColumnaNula := cont;

end;

PROCEDURE ActualizarTablaFilas(VAR tablaF: TTabla; dim: integer);
VAR
  j, i ,aux ,visible: integer;

BEGIN

  aux := 0; 
  i := 1;
  WHILE(i <= dim) DO BEGIN
    FOR j := MIN TO dim DO BEGIN
       IF(tablaF[i, j].activado = TRUE) THEN BEGIN
             visible := tablaF[i, j].visible;
             aux := aux + visible;
       END;
    END;{FOR}
     ActualizarSumatorioFila(tablaF, i, aux, dim);
    aux := 0;
    i := i + 1;
  END;{WHILE}

END;

PROCEDURE ActualizarTablaColumnas(VAR tablaC: TTabla; dim: integer);
VAR
  j, i, aux, visible: integer;

BEGIN

  aux := 0;
  j := 1;
  WHILE(j <= dim) DO BEGIN
    FOR i := MIN TO dim DO BEGIN
       IF(tablaC[i, j].activado = TRUE) THEN BEGIN
             visible := tablaC[i, j].visible;
             aux := aux + visible;
       END;
    END;{FOR}
     ActualizarSumatorioColumna(tablaC, j, aux, dim);
    aux := 0;
    j := j + 1;
  END;{WHILE}

END;

PROCEDURE InicializarTablaResultado(VAR tablaF: TTabla; VAR tablaC: TTabla; dim, rango, posDesactivables: integer);
VAR
  i, j, pos, fil, col, filaNula, columnaNula: integer;
BEGIN

  FOR i := MIN TO dim DO BEGIN
    FOR j := MIN TO dim DO BEGIN
      tablaF[i, j].visible := RANDOM(rango) + 1;
       tablaC[i, j].visible := tablaF[i, j].visible;
       tablaF[i, j].activado := TRUE;
       tablaC[i, j].activado := TRUE;
    END;
  end;

 pos := 0;
REPEAT
   col := RANDOM(dim) + 1;
   fil := RANDOM(dim) + 1;
   i := 1;
   j := 1;
   WHILE(i <> fil) DO
      i := i + 1;
   IF(i = fil) THEN BEGIN
      WHILE(j <> col) DO
        j := j + 1;
      IF(j = col) THEN BEGIN
         filaNula := VerificarNCeldasFilaNula(tablaF, i, dim);
         columnaNula := VerificarNCeldasColumnaNula(tablaC, j, dim);
         IF(filaNula <= pred(dim - 1)) AND (columnaNula <= pred(dim - 1)) AND (tablaF[i, j].activado = TRUE) THEN BEGIN
            tablaF[i, j].activado := FALSE;
            tablaC[i, j].activado := FALSE;
            pos := pos + 1;
         end;
      end;
   end;
 UNTIL(pos = posDesactivables);
 writeln;
 writeln;

  ActualizarTablaFilas(tablaF, dim);
 ActualizarTablaColumnas(tablaC, dim);

END;

PROCEDURE MostrarTabla(tablaF, tablaC, tablaF_Bis, tablaC_Bis: TTabla; dim: integer);
VAR   
  i, j, k: integer;
BEGIN

  textcolor(white); 
  FOR j := MIN TO dim DO
       WRITE(tablaC_Bis[1, j].sumable: 5);
  WRITELN;
  WRITELN;

  FOR j := MIN TO dim DO
       WRITE(tablaC[1, j].sumable: 5);
  WRITELN;
  WRITELN;
  WRITELN;

  k:=1;
  FOR i := MIN TO dim DO BEGIN
    FOR j := MIN TO dim DO BEGIN
       textcolor(lightred);
       IF(tablaF_Bis[i, j].activado = FALSE) THEN
            textcolor(white);
       WRITE(tablaF_Bis[i, j].visible: 5);//rellena las columnas de una fila
       textcolor(white);
    end;
    WRITE(tablaF[k, 1].sumable: 8);
    WRITE(tablaF_Bis[k, 1].sumable: 10);
    k := k + 1;
    WRITELN; //salta a la siguiente fila
  end;
  WRITELN;
  WRITELN;

END;

PROCEDURE Activacion(VAR tablaF: TTabla; VAR tablaC: TTabla; dim: integer);
VAR
  i, j: integer;
BEGIN

  FOR i := MIN TO dim DO BEGIN
    FOR j := MIN TO dim DO BEGIN
       tablaF[i, j].activado := TRUE;
       tablaC[i, j].activado := TRUE;
    end;
  end;

end;

PROCEDURE DuplicarTablas(tablaF, tablaC: TTabla; VAR tablaF_Bis, tablaC_Bis: TTabla; dim: integer);
VAR
  i, j: integer;
BEGIN

  Activacion(tablaF, tablaC, dim);
  FOR i := MIN TO dim DO BEGIN
    FOR j := MIN TO dim  DO BEGIN
      tablaF_Bis[i, j].visible := tablaF[i, j].visible;
      tablaF_Bis[i, j].activado := tablaF[i, j].activado;
      tablaC_Bis[i, j].visible := tablaC[i, j].visible;
      tablaC_Bis[i, j].activado := tablaC[i, j].activado;
    end;
  end;

end;

PROCEDURE InicializarTablaPartida(VAR tablaF_Bis: TTabla; VAR tablaC_Bis: TTabla; dim: integer);
VAR
  i, j, fil, col, aux, suma: integer;
BEGIN

  suma := 0;
  FOR i := MIN TO dim DO BEGIN
    FOR j := MIN TO dim DO BEGIN
      aux := tablaF_Bis[i, j].visible;
      suma := suma + aux;
    end;
    ActualizarSumatorioFila(tablaF_Bis, i, suma,dim);
    suma := 0;
  end;

  suma := 0;
  col := MIN;
  WHILE(col <= dim) DO BEGIN
    FOR fil := MIN TO dim DO BEGIN
      aux := tablaC_Bis[fil, col].visible;
      suma := suma + aux;
    end;
    ActualizarSumatorioColumna(tablaC_Bis, col, suma,dim);
    suma := 0;
    col := col + 1;
  end;

end;

FUNCTION JuegoFinalizado(tablaF_Bis, tablaF, tablaC_Bis, tablaC: TTabla; dim: integer):boolean;
VAR
  aux, FilasIguales, ColumnasIguales: boolean;
  i, j: integer;
BEGIN

  i := 1;
  j := 1;
  REPEAT
       IF(tablaF_Bis[i, j].sumable = tablaF[i, j].sumable) THEN
           aux := TRUE
        ELSE IF(tablaF_Bis[i, j].sumable <> tablaF[i, j].sumable) THEN
           aux := FALSE;
        i := i + 1;
        j := j + 1;
  UNTIL(aux = FALSE) OR ((i > dim) AND (j > dim));

  FilasIguales := aux;

  i := 1;
  j := 1;  
  REPEAT
       IF(tablaC_Bis[i, j].sumable = tablaC[i, j].sumable) THEN
           aux := TRUE
        ELSE IF(tablaC_Bis[i, j].sumable <> tablaC[i, j].sumable) THEN
           aux := FALSE;
        i := i + 1;
        j := j + 1;
  UNTIL(aux = FALSE) OR ((i > dim) AND (j > dim));

  ColumnasIguales := aux;

  JuegoFinalizado := (FilasIguales) AND (ColumnasIguales);

end;

FUNCTION ExistePartidaEnFichero(VAR fich:TFicheroPartidas;nombre:string):boolean;
VAR
  partida:TPartida;
  encontrado:boolean;
  ExistePartida:boolean;
BEGIN

 {$I-}
    RESET(fich);
 {$I+}
 IF(IORESULT=0)THEN BEGIN

    encontrado:=FALSE;
    WHILE(NOT EOF(fich))AND(encontrado=FALSE)DO BEGIN
       READ(fich,partida);
       encontrado:=(partida.nombreJugador=nombre);
    END;
    IF(encontrado)THEN
          ExistePartida:=TRUE
      ELSE IF(NOT encontrado)THEN
         ExistePartida:=FALSE;

    ExistePartidaEnFichero:=ExistePartida;
 END
 ELSE
    WRITELN('error verificacion');
close(fich);
end;

PROCEDURE SobreescribirFichero(VAR fich:TFicheroPartidas;nombre:string;numMovimientos:integer);
VAR
  partida:TPartida;
  encontrado:boolean;
BEGIN

 {$I-}
 RESET(fich);
 {$I+}
 IF(IORESULT=0)THEN BEGIN

    encontrado:=FALSE;
    WHILE(NOT EOF(fich))AND(encontrado=FALSE)DO BEGIN
       READ(fich,partida);
       encontrado:=(partida.nombreJugador=nombre);
    END;
    IF(encontrado)THEN BEGIN
        IF(numMovimientos<partida.puntuacion)THEN
            partida.puntuacion:=numMovimientos
        ELSE IF(numMovimientos>=partida.puntuacion)THEN BEGIN
           partida.puntuacion:=partida.puntuacion;
           WRITELN('su mejor puntuacion es: ',partida.puntuacion);
        END;
        SEEK(fich,FILEPOS(fich)-1);
        WRITE(fich,partida);
    END;
    WRITELN('PARTIDA ACTUALIZADA');

 END
 ELSE
   WRITELN('error de sobreescritura en el fichero');
close(fich);
end;

PROCEDURE GuardarP(VAR f:TFicheroPartidas;nombre:string;numMovimientos:integer;opcionPartida:char);
VAR
  partida:TPartida;
BEGIN

        RESET(f);
           seek(f,FILESIZE(f));
           partida.nombreJugador:=nombre;
           partida.puntuacion:=numMovimientos;
           partida.tipo:=opcionPartida;
           WRITE(f,partida);
    close(f);
    WRITELN('PARTIDA GUARDADA');
end;

PROCEDURE GuardarPartida(VAR fich:TFicheroPartidas;numMovimientos:integer;opcionPartida:char);
VAR

  nombre:string;
BEGIN

  WRITELN('Escriba su nombre para guardar la partida');
  READLN(nombre);


     IF(IORESULT<>0)THEN begin
        REWRITE(fich);
        GuardarP(fich,nombre,numMovimientos,opcionPartida)

     end
    ELSE BEGIN
         IF(ExistePartidaEnFichero(fich,nombre)=FALSE)THEN
           GuardarP(fich,nombre,numMovimientos,opcionPartida)
         ELSE IF(ExistePartidaEnFichero(fich,nombre)=TRUE)THEN
           SobreescribirFichero(fich,nombre,numMovimientos);
    end;


end; 

PROCEDURE OrdenarPartidas(VAR partidaArray:TArrayPartidas;VAR top:integer);
VAR
  i,j:integer;
  aux:TPartida;
BEGIN

  FOR i:=MIN TO pred(top)DO BEGIN
    FOR j:=MIN TO top-i DO BEGIN
      IF(partidaArray[j].puntuacion>partidaArray[j+1].puntuacion)THEN BEGIN
          aux:=partidaArray[j+1];
          partidaArray[j+1]:=partidaArray[j];
          partidaArray[j]:=aux;
      end;
    end;
  end;

end;

PROCEDURE Ranking(VAR fich:TFicheroPartidas);
VAR
  i,top:integer;
  partida:TPartida;
  partidaArray:TArrayPartidas;
BEGIN

  {$I-}
     RESET(fich);
  {$I+}
  IF(IORESULT<>0)THEN BEGIN
      WRITELN('ranking vacio');
      REWRITE(fich);
  end

  ELSE BEGIN

    top:=0;
    WHILE(NOT EOF(fich))DO BEGIN
        READ(fich,partida);
        top:=top+1;
        partidaArray[top].nombreJugador:=partida.nombreJugador;
        partidaArray[top].puntuacion:=partida.puntuacion;
        partidaArray[top].tipo:=partida.tipo;  ;
    END;

     OrdenarPartidas(partidaArray,top);

     FOR i:=MIN TO top DO BEGIN
        WRITELN('nombre del jugador: ',partidaArray[i].nombreJugador);
        WRITELN('puntuacion: ',partidaArray[i].puntuacion);
        WRITELN('tipo de partida: ',partidaArray[i].tipo);
        WRITELN;
     end;

  end;
  WRITELN('TECLEE CUALQUIER TECLA PARA VOLVER A INICIO');
  READLN;

close(fich);
END; 

PROCEDURE JugarPartida(VAR fich:TFicheroPartidas;tablaF, tablaC: TTabla; VAR tablaF_Bis: TTabla; VAR tablaC_Bis: TTabla; dimension: integer; VAR tope: integer; VAR partida: TArrayPartidas; opcionPartida: char);
VAR
  fila, columna, numMovimientos: integer;
  opcion: string[5];
BEGIN

   InicializarTablaPartida(tablaF_Bis, tablaC_Bis, dimension);

numMovimientos := 0;

REPEAT
  WRITELN('escriba -salir- si quiere abandonar la partida o teclee cualquier otra tecla si quiere continuar');
  READLN(opcion);
  IF(opcion = 'Salir') OR (opcion = 'SALIR') OR (opcion = 'salir') THEN BEGIN
     WRITELN('abandonando partida...');
     WRITELN;
     clrscr;
  END
  ELSE IF(opcion <> 'Salir') AND (opcion <> 'SALIR') AND (opcion <> 'salir') THEN BEGIN
     WRITELN('escriba la fila y columna de la cifra que quiere activar o desactivar');
     READ(fila);
     READLN(columna);
     clrscr;
  //cifra activada
     IF(tablaF_Bis[fila, columna].activado = TRUE) THEN BEGIN
        tablaF_Bis[fila, columna].activado := FALSE;//desactivar
        tablaC_Bis[fila, columna].activado := FALSE;
        ActualizarFila(tablaF_Bis, fila, dimension);
        ActualizarColumna(tablaC_Bis, columna, dimension);
        MostrarTabla(tablaF, tablaC, tablaF_Bis, tablaC_Bis, dimension);
        numMovimientos := numMovimientos + 1;
     end
  //cifra desactivada
     ELSE IF(tablaF_Bis[fila, columna].activado = FALSE) THEN BEGIN
        tablaF_Bis[fila, columna].activado := TRUE; //activar
        tablaC_Bis[fila, columna].activado := TRUE;
        tablaF_Bis[fila, columna].visible := tablaF[fila, columna].visible;
        tablaC_Bis[fila, columna].visible := tablaC[fila, columna].visible;
        ActualizarFila(tablaF_Bis, fila, dimension);
        ActualizarColumna(tablaC_Bis, columna, dimension);
        MostrarTabla(tablaF, tablaC, tablaF_Bis, tablaC_Bis, dimension);
        numMovimientos := numMovimientos + 1;
     end;
  end;
UNTIL(opcion = 'Salir') OR (opcion = 'SALIR') OR (opcion = 'salir') OR (JuegoFinalizado(tablaF_Bis, tablaF, tablaC_Bis, tablaC, dimension));
IF(JuegoFinalizado(tablaF_Bis, tablaF, tablaC_Bis, tablaC, dimension)) THEN BEGIN
    WRITELN('enhorabuena!!!!');
    WRITELN('numero movimientos totales: ', numMovimientos);
    GuardarPartida(fich, numMovimientos, opcionPartida);
END;

end;
PROCEDURE InicializarPartida(VAR fich:TFicheroPartidas; dimension, rango, posDesactivable: integer; opcionPartida: char);
VAR
  tablaF, tablaC, tablaF_Bis, tablaC_Bis: TTabla;
BEGIN

                InicializarTablaResultado(tablaF, tablaC, dimension, rango, posDesactivable);
                DuplicarTablas(tablaF, tablaC, tablaF_Bis, tablaC_Bis, dimension);
                InicializarTablaPartida(tablaF_Bis, tablaC_Bis, dimension);
                MostrarTabla(tablaF, tablaC, tablaF_Bis, tablaC_Bis, dimension);
                JugarPartida(tablaF, tablaC, tablaF_Bis, tablaC_Bis, dimension, opcionPartida);

end;

PROCEDURE Juego(VAR fich:TFicheroPartidas);
VAR
  dimension, rango, posDesactivable: integer;
  opcionPartida: char;
BEGIN

    opcionPartida:=ElegirPartida;
    CASE opcionPartida OF
      'A','B','C': BEGIN
                   rango:= 9; dimension:= ord(opcionPartida) - 60; 
                   posDesactivable:= dimension*2;
                   END;
      'D','E','F': BEGIN
                   rango:= 19; dimension:= ord(opcionPartida) - 63; 
                   posDesactivable:= dimension*2;
                   END;
      END;{CASE}
      
InicializarPartida(fich, dimension, rango, posDesactivable, opcionPartida);

END;

PROCEDURE OpcionesDelMenu;
//con esta función se muestra por pantalla las opciones disponibles antes de jugar, aparecerá nada más entrar en la app
BEGIN

  WRITELN(' MENU ');
  WRITELN('[1] Obtener ayuda');
  WRITELN('[2] Elegir partida');
  WRITELN('[3] Leer ranking');
  WRITELN('[4] Salir');

END;

PROCEDURE MenuPrincipalDelJuego(VAR fich:TFicheroPartidas);
//el usuario seleccionará una de las tres opciones del menu, esto se repetirá tantas veces hasta que el usuario seleccione una opción del menú, después será un case
VAR
  opcionMenu: integer;

BEGIN

  WRITELN('!!! BIENVENIDO AL JUEGO DEL RULO !!!');
  WRITELN;
  WRITELN(' MODO CLASICO ');
  WRITELN;
REPEAT

  REPEAT
     OpcionesDelMenu;
     WRITELN;
     WRITELN('seleccione una opcion del menu: 1, 2, 3 o 4');
     READLN(opcionMenu);
     IF(opcionMenu < 1) OR (opcionMenu > 4) THEN BEGIN
        WRITELN('seleccion erronea, pruebe otra vez');
        WRITELN;
     end;
  until(opcionMenu >= 1) AND (opcionMenu <= 4);

  CASE opcionMenu OF
     1:BEGIN
       CLRSCR;
       Ayuda;
     end;
     2:BEGIN
       CLRSCR;
       Juego(fich);
     end;
     3:BEGIN
       CLRSCR;
       Ranking(fich);
       CLRSCR;
     end;
     4:BEGIN
       CLRSCR;
       WRITELN(' HASTA PRONTO! ');
     end;
  END;


until(opcionMenu = 4);

END;

BEGIN

  RANDOMIZE;
  ASSIGN(fich,'E:\Partidas.bin');
  MenuPrincipalDelJuego(fich);

READLN;
END.
                                                

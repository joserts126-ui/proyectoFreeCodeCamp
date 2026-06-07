#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.
# Limpiar las tablas antes de cada ejecución para evitar datos duplicados si corres el script varias veces
echo $($PSQL "TRUNCATE TABLE games, teams;")

# Leer el archivo games.csv línea por línea
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Ignorar la primera fila
  if [[ $YEAR != "year" ]]
  then
    #insertar equipos / uso de on conflict y do nothing para no repetir equipos 
    INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER') ON CONFLICT (name) DO NOTHING;")
    INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT') ON CONFLICT (name) DO NOTHING;")
    #obtener id de winner y opponent
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER';")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT';")

    #insertar info en tabla games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS);")
    
    # Imprimir confirmación opcional en la terminal para el proceso
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Insertado en games: $YEAR $ROUND - $WINNER vs $OPPONENT"
    fi

  fi
done
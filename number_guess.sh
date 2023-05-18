#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USERNAME
USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

#if user does not exists
if [[ -z $USER_ID ]]
then
  if [[ ${#USERNAME} -le 22 ]]
  then
    # insert major
    INSERT_USER=$($PSQL "insert into users(username) values('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    #get user id
    USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
  else
  echo "Your username must be less or equal to 22 characters"
  fi
else
COUNT_GAMES=$($PSQL "select count(*) from games where user_id='$USER_ID'")
BEST_SCORE=$($PSQL "select min(number_of_guesses) from games where user_id='$USER_ID'")
echo "Welcome back, $USERNAME! You have played $COUNT_GAMES games, and your best game took $BEST_SCORE guesses."
fi

CORRECT_NUMBER=$(($RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read USER_GUESS

until [[ "$USER_GUESS" -eq "$CORRECT_NUMBER" ]]
do
  if ! [[ $USER_GUESS =~ ^[0-9]+$ ]] ; 
  then 
    echo "That is not an integer, guess again:"
    read USER_GUESS
  else
    if [[ "$USER_GUESS" -gt "CORRECT_NUMBER" ]]
    then
      let "NUMBER_OF_GUESSES+=1"
      echo "It's lower than that, guess again:";
      read USER_GUESS
    fi

    if [[ "$USER_GUESS" -lt "CORRECT_NUMBER" ]]
    then
      let "NUMBER_OF_GUESSES+=1"
      echo "It's higher than that, guess again:";
      read USER_GUESS
    fi

    if [[ "$USER_GUESS" -eq "$CORRECT_NUMBER" ]]
    then
    let "NUMBER_OF_GUESSES+=1"
    INSERT_GAME=$($PSQL "insert into games(user_id, number_of_guesses) values($USER_ID, $NUMBER_OF_GUESSES)")
    echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $CORRECT_NUMBER. Nice job!"
    exit
    fi
  fi
done

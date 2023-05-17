#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

MAIN()
{
echo -e " \nEnter your username:"
read USERNAME
USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")

#if user does not exists
if [[ -z $USER_ID ]]
then
  INSERT_USER
else
COUNT_GAMES=$($PSQL "select count(*) from games where user_id='$USER_ID'")
BEST_SCORE=$($PSQL "select min(number_of_guesses) from games where user_id='$USER_ID'")
echo -e "Welcome back, $USERNAME! You have played $COUNT_GAMES games, and your best game took $BEST_SCORE guesses."
fi

CORRECT_NUMBER=$(($RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo -e "Guess the secret number between 1 and 1000:"

read USER_GUESS

until [[ "$USER_GUESS" -eq "$CORRECT_NUMBER" ]]
do
  if ! [[ $USER_GUESS =~ ^[0-9]+$ ]] ; 
  then 
    echo "That is not an integer, guess again:"
    read USER_GUESS
    let "NUMBER_OF_GUESSES+=1"
  else
    if [[ "$USER_GUESS" -gt "CORRECT_NUMBER" ]]
    then
      echo "It's lower than that, guess again:";
      read USER_GUESS
      let "NUMBER_OF_GUESSES+=1"
    fi

    if [[ "$USER_GUESS" -lt "CORRECT_NUMBER" ]]
    then
      echo "It's higher than that, guess again:";
      read USER_GUESS
      let "NUMBER_OF_GUESSES+=1"
    fi
  fi
done

let "NUMBER_OF_GUESSES+=1"

if [[ "$USER_GUESS" -eq "$CORRECT_NUMBER" ]]
  then
    let "NUMBER_OF_GUESSES+=1"
    INSERT_GAME=$($PSQL "insert into games(user_id, number_of_guesses) values($USER_ID, $NUMBER_OF_GUESSES)")
    if [[ $INSERT_GAME == "INSERT 0 1" ]]
    then
      echo -e "\nYou guessed it in $NUMBER_OF_GUESSES tries. The secret number was $CORRECT_NUMBER. Nice job!"
    fi
  fi

}

INSERT_USER()
{
  if [[ ${#USERNAME} -le 22 ]]
  then
    # insert major
    INSERT_USER=$($PSQL "insert into users(username) values('$USERNAME')")
    if [[ $INSERT_USER == "INSERT 0 1" ]]
    then
      echo "Welcome, $USERNAME! It looks like this is your first time here."
      #get user id
      USER_ID=$($PSQL "select user_id from users where username='$USERNAME'")
    fi
  else
  echo -e "Your username must be less or equal to 22 characters"
  fi
}

MAIN

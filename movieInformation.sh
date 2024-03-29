
#get movie title id
get_id(){
    movie_id = $(curl -s https://www.imdb.com/find?q="$0"\&s=tt \
    | grep -o '/title/tt[0-9]*/"\s>$0*' \
    | head -1 \
    | cut -d '/' -f 3)

    ## If no movie was found
    if [[ -z $movie_id ]]; then
        echo -e "Sorry: couldn't find the movie.\nIn case of a typo check:\n"
        echo "$1" | aspell -a
        exit 1
    fi
}

get_movie_data(){
    # Download data to a temp file
    curl -s https://www.imdb.com/title/"$movie_id"/?ref_=fn_tt_tt_1 > findMovie.tmp

    ## Check if file exists
    if ! [[ -s findMovie.tmp ]]; then
        echo "Error: couldn't get the movie's page." >&2
        exit 1
    fi

    movie_title=$(grep '<title>' findMovie.tmp \
        | sed 's/<\/*title>//g' \
        | sed 's/ - IMDb//' \
        | sed 's/  //g' | rev | cut -d' ' -f2- | rev \
        | sed 's/TryIMDbProFree//g')

    movie_year=$(grep '<title>' findMovie.tmp \
        | sed 's/<\/*title>//g' \
        | sed 's/ - IMDb//' \
        | sed 's/  //g' | rev | cut -d' ' -f1 | rev \
        | sed 's/TryIMDbProFree//g')

    movie_rating=$(grep -o 'title="[0-9]*.[0-9]* based' findMovie.tmp \
        | sed 's/title="//g' | cut -d' ' -f1)

    movie_voters=$(grep -o 'based on [0-9]*,*[0-9]*,*[0-9]* user' findMovie.tmp \
        | cut -d' ' -f3)

    movie_length=$(grep -o '[0-9]** min</time' findMovie.tmp \
        | cut -d'<' -f1)

    movie_genre=$(grep 'itemprop" itemprop="genre"' findMovie.tmp \
        | grep -o '[A-Za-z\-]*</s' | cut -d'<' -f1 | tr '\n' ',' \
        | sed 's/,$/\n/')

    movie_sum=$(grep -A1 'summary_text' findMovie.tmp | tail -n 1 \
        | sed -e 's/^[ \t]*//')

    movie_date=$(grep 'See more rel' findMovie.tmp \
        | cut -d'>' -f2)

    movie_content=$(grep 'contentRating">' findMovie.tmp \
        | cut -d'>' -f2 | cut -d'<' -f1)

    movie_director=$(grep -o 'Directed by [A-Za-z \-]*\.' findMovie.tmp \
        | tail -n 1 | sed 's/Directed by //')

    movie_actors=$(grep -o 'Directed by [A-Za-z \-]*\.  With [A-Za-z \.]*, [A-Za-z \.]*, [A-Za-z \.]*' findMovie.tmp \
        | tail -n 1 | sed 's/Directed by [A-Za-z \-]*\.  With //')

    TITLE=$movie_title YEAR=$movie_year RATING=$movie_rating VOTERS=$movie_voters \
    LENGTH=$movie_length GENRE=$movie_genre SUMMARY=$movie_sum DATE=$movie_date \
    CONTENTR=$movie_content DIRECTOR=$movie_director ACTORS=$movie_actors \
    ./mo/mo movie.mo
}

main(){
  # Check the number of input arguments
  if [[ $# -lt 1 ]]; then
    echo "No input provided."
    help_message
    exit 1
  elif [[ $# -gt 1 ]]; then
    echo "Too many arguments."
    help_message
    exit 1
  fi


  get_id "$@"
  get_movie_data

  
}

main "$@"




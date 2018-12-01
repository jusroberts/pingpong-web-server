// # Place all the behaviors and hooks related to the matching controller here.
// # All this logic will automatically be available in application.js.
// # You can use CoffeeScript in this file: http://coffeescript.org/

// Variables included from the template:
/**
 * @type {number} playerCount
 * @type {Object.<string, Array.<number>>} playerIdHash
 * @type {string} pageType
 * @type {string} default_team_a_avatar
 * @type {string} default_team_b_avatar
 * @type {number} wesId
 */

const wesId = 20;

class Utilities {
    static sleep(time) {
        return new Promise((resolve) => setTimeout(resolve, time));
    }
}

class BackgroundHandler {
    setUpBackground() {
        let background = "url(\"/images/match_backgrounds/bg_";
        background += Math.floor(Math.random() * 120) + 1;
        background += ".gif\")";
        background += " no-repeat center center fixed";
        $(".rooms.show").css({
            "background": background,
            "-webkit-background-size": "cover", /* For WebKit*/
            "-moz-background-size": "cover",    /* Mozilla*/
            "-o-background-size": "cover",      /* Opera*/
            "background-size": "cover"         /* Generic*/
        });
        $(".rooms.game_play").css({
            "background": background,
            "-webkit-background-size": "cover", /* For WebKit*/
            "-moz-background-size": "cover",    /* Mozilla*/
            "-o-background-size": "cover",      /* Opera*/
            "background-size": "cover"         /* Generic*/
        });
        $(".rooms.game_view").css({
            "background": background,
            "-webkit-background-size": "cover", /* For WebKit*/
            "-moz-background-size": "cover",    /* Mozilla*/
            "-o-background-size": "cover",      /* Opera*/
            "background-size": "cover"         /* Generic*/
        });
        $(".rooms.home").css({
            "background": background,
            "-webkit-background-size": "cover", /* For WebKit*/
            "-moz-background-size": "cover",    /* Mozilla*/
            "-o-background-size": "cover",      /* Opera*/
            "background-size": "cover"         /* Generic*/
        });
    }
}

/**
 * @class
 * @property {Audio} audio
 * @property {number} lastTeamAScore
 * @property {number} lastTeamBScore
 */
class RunningGameFunctions {
    constructor(audio) {
        this.audio = audio;
        this.lastTeamAScore = 0;
        this.lastTeamBScore = 0;

        let quitButton = document.querySelector('.sf-quit');
        if (quitButton) {
            quitButton.addEventListener('click', function(event) {
                let targetElement = event.target || event.srcElement;
                console.log("Quit clicked by " + targetElement);
            });
        }
    }

    updateScore(teamAScore, teamBScore) {
        if (teamAScore != this.lastTeamAScore) {
            this.scoreA(teamAScore);
            this.lastTeamAScore = teamAScore;
        }
        if (teamBScore != this.lastTeamBScore) {
            this.scoreB(teamBScore);
            this.lastTeamBScore = teamBScore;
        }
        console.log("HandleScoreUpdate teamA: " + teamAScore + ", teamB: " + teamBScore);
        this.audio.handleScoreUpdate(teamAScore, teamBScore);
    }

    taunt(team) {
        this.audio.playTaunt(team);
    }

    scoreA(score) {
        this.lastTeamAScore = score;
        console.log("TEAM A SCORE = " + score);
        if (score === 'W') {
            $("#team_a_status").css({
                "background": 'url("/images/pong_assets/winner-animation.gif")',
                "background-size": "75%",
                "background-position": "center",
                "background-repeat": "no-repeat"
            });
            $("#b_meter").animate({width: "0%"});
            RunningGameFunctions.startContinueCountdown();
        } else if (score === 'G') {
            $("#b_meter").animate({width: (100 / 21) + "%"});
        } else if (score === 'D') {
            $("#b_meter").animate({width: "100%"});
            $("#b_meter").css({"background": "#ED1C24"});
        } else if (score === 'ADV') {
            $("#a_meter").animate({width: "100%"});
            $("#b_meter").animate({width: "50%"});
            $("#a_meter").css({"background": "#ED1C24"});
            $("#b_meter").css({"background": "#ED1C24"});
        } else {
            $("#team_a_status").text('\xa0');
            $("#b_meter").animate({width: ((21 - score) * 100 / 21) + "%"});
        }
        $("#team_a_score").text(score);
    }

    scoreB(score) {
        this.lastTeamBScore = score;
        console.log("TEAM B SCORE = " + score);
        if (score === 'W') {
            $("#team_b_status").css({
                "background": 'url("/images/pong_assets/winner-animation.gif")',
                "background-size": "75%",
                "background-position": "center",
                "background-repeat": "no-repeat"
            });
            $("#a_meter").animate({width: "0%"});
            RunningGameFunctions.startContinueCountdown();
        } else if (score === 'G') {
            $("#a_meter").animate({width: (100 / 21) + "%"});
        } else if (score === 'D') {
            $("#a_meter").animate({width: "100%"});
            $("#a_meter").css({"background": "#ED1C24"});
        } else if (score === 'ADV') {
            $("#b_meter").animate({width: "100%"});
            $("#a_meter").animate({width: "50%"});
            $("#a_meter").css({"background": "#ED1C24"});
            $("#b_meter").css({"background": "#ED1C24"});
        } else {
            $("#team_b_status").text('\xa0');
            $("#a_meter").animate({width: ((21 - score) * 100 / 21) + "%"});
        }
        $("#team_b_score").text(score);
    }

    static startContinueCountdown() {
        console.log("startContinueCountdown");
        $("#continueButton").css({"display": "block"});
        $("#continueButton").focus();
        let counter = 10;
        let id;
        id = setInterval(function () {
            counter--;
            let backgroundUrl;
            if (counter <= 0) {
                 backgroundUrl = "url('/images/pong_assets/pong_continue 01.png')"
                $("#continueButton").css("background-image", backgroundUrl);
                clearInterval(id);
                $(".sf-quit").trigger('click');
            } else {
                backgroundUrl = "url('/images/pong_assets/pong_continue 0" + counter + ".png')"
                $("#continueButton").css("background-image", backgroundUrl);
            }
        }, 1000);
    }
}

class ApiActions {
    static clearPlayers() {
        return $.post("new/players/clear")
            .done(function() {
                console.log("Player clear POST succeeded");
                playerIdHash = {
                    a: [],
                    b: []
                };
                $('.player-ranking').text('');
                $(".player_a_1_img").attr("src", default_team_a_avatar);
                $(".player_a_2_img").attr("src", default_team_a_avatar);
                $(".player_b_1_img").attr("src", default_team_b_avatar);
                $(".player_b_2_img").attr("src", default_team_b_avatar);
                NewGameFunctions.updateScanPlayerButton($("#scanLabel"), playerCount, playerIdHash);
                NewGameFunctions.updatePrediction();
            })
            .fail(function() {
                console.log("Player clear POST failed");
            })
    }

    static optimizePlayers(playerIds) {
        let roomId = $('#room-id').text();
        return $.get('/api/rooms/' + roomId + '/players/optimize',
            {
                players: playerIds.join(',')
            }
        ).done(function (data) {
            console.log("Team optimization GET succeeded");
        }).fail(function() {
            console.log("Team optimization POST failed");
        });
    }

    static predictGame(playerIdHash) {
        let roomId = $('#room-id').text();
        return $.get('/api/rooms/' + roomId + '/players/predict',
            {
                playerIdHash: playerIdHash
            }
        ).then(function (data) {
            console.log("Predict game GET succeeded");
            return {
                favoredTeam: data.favoredTeam,
                pointSpread: data.pointSpread
            };
        }, function() {
            console.log("Predict game POST failed");
        });
    }

    static getRankings(playerIds) {
        let roomId = $('#room-id').text();
        return $.get('/api/rooms/' + roomId + '/players/rank',
            {
                playerIds: playerIds
            }
        ).done(function (data) {
            console.log("Ranking GET succeeded");
        }).fail(function() {
            console.log("Ranking GET failed");
        });
    }
}

class NewGameFunctions {
    static setUpNewGameEventHandlers() {
        $("#scanButton").click(function () {
            // Optimizing singles makes no sense
            if (playerCount == 4) {
                NewGameFunctions.optimizeTeams();
            }
        });
      $("#singlesButton").click(function () {
            NewGameFunctions.updatePlayerCount(2, $("#singlesButton"), $("#doublesButton"));
        });
        $("#doublesButton").click(function () {
            NewGameFunctions.updatePlayerCount(4, $("#doublesButton"), $("#singlesButton"));
        });

        $("#clearButton").click(function (e) {
            // Wipe all the players
            ApiActions.clearPlayers();
        });
    }

    static updatePlayerCount(count, selectedElement, unselectedElement) {
        $.post("player_count", {player_count: count})
            .done(function () {
                console.log("Player mode change to " + count + " succeeded");
                selectedElement.addClass("selected");
                unselectedElement.removeClass("selected");
                playerCount = count;
                NewGameFunctions.displayForPlayerCount(playerCount);
                playerIdHash['a'].splice(1, 1);
                playerIdHash['b'].splice(1, 1);
                NewGameFunctions.updateScanPlayerButton($("#scanLabel"), playerCount, playerIdHash);
                NewGameFunctions.updatePrediction();
            })
            .fail(function () {
                console.log("Player mode change POST failed");
            })
    }

    static displayForPlayerCount(count) {
        if (count == 2) {
            $(".doubles-picturebox").hide();
            $(".singles-picturebox").show();
            $(".player_a_2_img").attr("src", default_team_a_avatar);
            $(".player_b_2_img").attr("src", default_team_b_avatar);
        } else if (count == 4) {
            $(".doubles-picturebox").show();
            $(".singles-picturebox").hide();
        } else {
            console.log("Invalid player count " + count + " passed to displayForPlayerCount");
        }
    }

    static updatePlayerIdObject(newPlayerData, playerIds) {
        playerIds[newPlayerData['team']][newPlayerData['player_number'] - 1] = newPlayerData['player_id'];
    }

    static updateScanPlayerButton(button, playerCount, playerIds) {
        let teamA = playerIds['a'];
        let teamB = playerIds['b'];
        let scanButton = $('#scanButton');
        let scanLabel = $('#scanLabel');

        scanButton.removeClass('hoverable');
        scanLabel.removeClass('hoverable');
        if (playerCount == 2) {
            // Singles
            if (teamA.length == 0) {
                button.text('SCAN PLAYER 1');
            } else if (teamB.length == 0) {
                button.text('SCAN PLAYER 2');
            } else {
                button.text('LET\'S ROCK!');
            }
        } else {
            // Doubles
            if (teamA.length == 0) {
                button.text('SCAN PLAYER A-1');
            } else if (teamA.length < 2) {
                button.text('SCAN PLAYER A-2');
            } else if (teamB.length == 0) {
                button.text('SCAN PLAYER B-1');
            } else if (teamB.length < 2) {
                button.text('SCAN PLAYER B-2');
            } else {
                scanButton.addClass('hoverable');
                scanLabel.addClass('hoverable');
                button.text('BALANCE TEAMS');
            }
        }
    }

    static updatePrediction() {
        if (NewGameFunctions.isGameFull()) {
            NewGameFunctions.predictGame();
        } else {
            NewGameFunctions.displayPrediction('hide', 'a');
            NewGameFunctions.displayPrediction('hide', 'b');
        }
    }

    static displayPrediction(toggleAction, team) {
        let teamAStar = $('#team_a_star');
        let teamAFavored = $('#team_a_favored');
        let teamBStar = $('#team_b_star');
        let teamBFavored = $('#team_b_favored');

        if (toggleAction == 'show') {
            if (team == 'a') {
                teamAStar.show();
                teamAFavored.show();
            } else if (team == 'b') {
                teamBStar.show();
                teamBFavored.show();
            }
        } else if (toggleAction == 'hide') {
            if (team == 'a') {
                teamAStar.hide();
                teamAFavored.hide();
            } else if (team == 'b') {
                teamBStar.hide();
                teamBFavored.hide();
            }
        }
    }

    static optimizeTeams() {
        // Only allow optimizing if everyone's signed in
        if (playerIdHash.a.length != 2 || playerIdHash.b.length != 2) {
            return;
        }

        let playerIds = playerIdHash.a.concat(playerIdHash.b);
        ApiActions.clearPlayers()
            .then(function() {
                console.log('Clear callback completed');
                // Once we've cleared the current players, run the optimize call to repopulate them
                return ApiActions.optimizePlayers(playerIds);
            }).then(function(data) {
                console.log('Optimize callback completed');
                playerIdHash = data;
            });
    }

    static predictGame() {
        ApiActions.predictGame(playerIdHash)
            .done(function(data) {
                console.log('Predict callback completed');
                let {
                    favoredTeam,
                    pointSpread
                } = data;
                let teamAFavored = $('#team_a_favored');
                let teamBFavored = $('#team_b_favored');

                if (favoredTeam == 'a') {
                    NewGameFunctions.displayPrediction('show', 'a');
                    NewGameFunctions.displayPrediction('hide', 'b');
                    teamAFavored.text('+' + pointSpread);
                } else if (favoredTeam == 'b') {
                    NewGameFunctions.displayPrediction('show', 'b');
                    NewGameFunctions.displayPrediction('hide', 'a');
                    teamBFavored.text('+' + pointSpread);
                } else {
                    console.log('Invalid game prediction response' + JSON.stringify(data));
                }
            });
    }

    static updateRankings() {
        let playerIds = playerIdHash.a.concat(playerIdHash.b);
        // Clear all existing rankings
        $('.player-ranking').text('');
        ApiActions.getRankings(playerIds)
            .done(function (data) {
                console.log('Get rankings callback completed ' + JSON.stringify(data));

                for (let playerIdString in data) {
                    let playerId = parseInt(playerIdString, 10);
                    if (data.hasOwnProperty(playerId)) {
                        let playerRank = data[playerId];
                        let rankingTextElement = NewGameFunctions.getRankingTextElement(playerId);
                        if (rankingTextElement) {
                            rankingTextElement.text(playerRank);
                        }
                    }
                }
            });
    }

    static isGameFull() {
        return (
            (playerCount == 2 && playerIdHash.a.length == 1 && playerIdHash.b.length == 1) ||
            (playerCount == 4 && playerIdHash.a.length == 2 && playerIdHash.b.length == 2)
        );
    }

    static getRankingTextElement(playerId) {
        let indexA = playerIdHash.a.indexOf(playerId);
        let indexB = playerIdHash.b.indexOf(playerId);

        if (indexA >= 0) {
            return $(`.player_a_${indexA + 1}_ranking`);
        } else if (indexB >= 0) {
            return $(`.player_b_${indexB + 1}_ranking`);
        }

        return null;
    }
}

/**
 * @class
 */
class Players {
    /**
     * @param {Object.<string, Array.<number>>} playerIdHash
     * @param {number} playerId
     */
    static getPlayerTeam(playerIdHash, playerId) {
        if (playerIdHash.a.indexOf(playerId) >= 0) {
            return 'a';
        }
        if (playerIdHash.b.indexOf(playerId) >= 0) {
            return 'b';
        }
        return null;
    }
}

/**
 * @class
 * @property {Object.<string, string>} audioElements
 * @property {number} scoringStreak Number of unanswered points scored; positive is team A and vice versa
 */
class Audio {

    constructor() {
        this.audioElements = {};
        this.lastTeamAScore = 0;
        this.lastTeamBScore = 0;
        this.scoringStreak = 0;
        this.interSoundDelayMillis = 200;
        this.lastPromise = new Promise(function(resolve) {resolve()});
        this.lastServingTeam = null;
        //Add all the taunts to this list
        this.taunts = [
            "bitelegs",
            "bleed",
            "evil_laugh",
            "fart",
            "hamster",
            "homer_doh",
            "horn_fail",
            "last_chance",
            "king_of_the_hill_loser",
            "mocking_laugh",
            "patrick_pain_train",
            "runaway",
            "sad_trombone",
            "say_bye_bye",
            "tf2_you_failed",
            "trololo",
            "trololo_full",
            "wrecked_son",
            "you_are_dead",
            "you_failed",
            "you_loose",
            "you_shall_not_pass",
            "you_suck"];

        this.wesTeam = Players.getPlayerTeam(playerIdHash, wesId);
        if (this.wesTeam) {
            //If wes is playing, add these taunts
            this.taunts.push("dammit_wes2");
            this.taunts.push("dammit_wes");
        }
        this.lastTauntIndex = 0;
    }

    playTaunt(team) {

        //Play a random taunt and avoid playing the same taunt twice in a row
        let numberOfTries = 0;
        let tauntIndex = this.lastTauntIndex;
        do {
            tauntIndex = Math.floor(Math.random() * this.taunts.length);
            numberOfTries++;
        } while (numberOfTries < 10 && tauntIndex == this.lastTauntIndex);

        this.lastTauntIndex = tauntIndex;
        let tauntKey = this.taunts[tauntIndex];

        this.playSound(tauntKey);
        Utilities.sleep(this.interSoundDelayMillis);
        console.log('Playing taunt: ' + tauntKey);
    }

    /**
     * @param {number} teamAScore
     * @param {number} teamBScore
     */
    handleScoreUpdate(teamAScore, teamBScore) {
        let audio = this;
        // Get an array of sounds to play
        let sounds = this.getSoundsToPlay(teamAScore, teamBScore);
        console.log('Playing sounds: ' + JSON.stringify(sounds));

        // Play each sound in sequence, to completion
        let promise = this.lastPromise;
        sounds.forEach(function(soundKey, index) {
            promise = promise
                .then(function() {
                    console.log('Playing ' + (index + 1) + ' sound ' + soundKey);
                    return audio.playSound(soundKey);
                })
                .then(function() {
                    console.log('Sleep ' + (index + 1));
                    return Utilities.sleep(audio.interSoundDelayMillis);
                })
        });

        this.lastPromise = promise;
    }

    getSoundsToPlay(teamAScore, teamBScore) {
        // Add the filename strings for any sounds that should play for this scoring event to the sounds array
        let sounds = [];
        let teamAScoreNumeric = null;
        let teamBScoreNumeric = null;
        let teamAIncrement = null;
        let teamBIncrement = null;
        let servingTeam = null;
        let wesTeam = Players.getPlayerTeam(playerIdHash, wesId);

        // Do some parsing
        if (isNaN(teamAScore)) {
            if (teamAScore == "W" ||
                (teamAScore == "G" && this.lastTeamAScore != "G")) {
                teamAIncrement = 1;
            }
        } else {
            teamAScoreNumeric = parseInt(teamAScore, 10);
            teamAIncrement = teamAScoreNumeric - this.lastTeamAScore;
        }
        if (isNaN(teamBScore)) {
            if (teamBScore == "W" ||
                (teamBScore == "G" && this.lastTeamBScore != "G")) {
                teamBIncrement = 1;
            }
        } else {
            teamBScoreNumeric = parseInt(teamBScore, 10);
            teamBIncrement = teamBScoreNumeric - this.lastTeamBScore;
        }

        // Populate some sounds

        //decrement score
        if (teamAIncrement < 0) {
            sounds.push("oopsie");
            //fix the streak
            if (this.scoringStreak > 0) {
                this.scoringStreak--;
            }
        }
        else if (teamBIncrement < 0) {
            sounds.push("oops");
            //fix the streak
            if (this.scoringStreak < 0) {
                this.scoringStreak++;
            }
        }

        // Streak logic
        else if (teamAIncrement > 0) {
            // Team A scored
            if (wesTeam) {
                sounds.push('beep');
            } else {
                sounds.push('pong_beep');
            }
            // If Team B has a streak going
            if (this.scoringStreak < 0) {
                // Reset the streak
                this.scoringStreak = 0;
            }
            this.scoringStreak++;
        }
        else if (teamBIncrement > 0) {
            // Team B scored
            if (wesTeam) {
                sounds.push('boop');
            } else {
                sounds.push('pong_boop');
            }
            // If Team A has a streak going
            if (this.scoringStreak > 0) {
                // Reset the streak
                this.scoringStreak = 0;
            }
            this.scoringStreak--;
        }
        console.log('Scoring streak: ' + this.scoringStreak);
        if (Math.abs(this.scoringStreak) == 5) {
            sounds.push('rampage');
        }
        if (Math.abs(this.scoringStreak) == 10) {
            sounds.push('untouchable');
        }
        if (Math.abs(this.scoringStreak) == 15) {
            sounds.push('invincible');
        }
        if (Math.abs(this.scoringStreak) == 20) {
            sounds.push('inconceivable');
        }
        // Yell at Wes
        if (wesTeam == 'a' && this.scoringStreak <= -5) {
            sounds.push('dammit_wes');
        }
        if (wesTeam == 'b' && this.scoringStreak >= 5) {
            sounds.push('dammit_wes2');
        }

        // Serving change logic
        if (teamAScoreNumeric && teamBScoreNumeric && ((teamAScoreNumeric + teamBScoreNumeric) % 5 == 0)) {
            sounds.push('change_places');
        }
        if (teamAScore == 'G') {
            servingTeam = 'b';
            // sounds.push('change_places');
        }
        if (teamAScore == 'ADV') {
            servingTeam = 'b';
            if (this.lastServingTeam && this.lastServingTeam != servingTeam) {
                sounds.push('change_places');
            }
        }
        if (teamBScore == 'G') {
            servingTeam = 'a';
            // sounds.push('change_places');
        }
        if (teamBScore == 'ADV') {
            servingTeam = 'a';
            if (this.lastServingTeam && this.lastServingTeam != servingTeam) {
                sounds.push('change_places');
            }
        }
        if (teamAScore == 'D') {
            // If it's deuce, swap serving team. Keep track so we can tell when we have a switch
            servingTeam = this.lastServingTeam == 'a' ? 'b' : 'a';
            sounds.push('change_places');
        }

        // Game over etc.
        if (teamAScore == 'W' || teamBScore == 'W') {
            sounds.push('game_over');
        }
        if (teamAScoreNumeric == 4 && teamBScoreNumeric == 4) {
            sounds.push('fours');
        }

        this.lastServingTeam = servingTeam;
        this.lastTeamAScore = teamAScore;
        this.lastTeamBScore = teamBScore;
        return sounds;
    }

    playSound(key) {
        let audio = this;
        // All audio files in public/audio should be automatically loaded as <audio> elements in the template
        // The key here is the filename sans extension
        if (!this.audioElements.hasOwnProperty(key)) {
            this.audioElements[key] = document.querySelector('#' + key);
        }
        this.audioElements[key].play();
        return new Promise(function(resolve, reject) {
            audio.audioElements[key].addEventListener('ended', resolve);
            audio.audioElements[key].addEventListener('error', reject);
        });
    }
}


/**
 * Initialize page on load
 */
$(document).ready( function() {
    console.log('rooms JS init');
    let audio = new Audio();
    let runningGame = new RunningGameFunctions(audio);
    let socketHandler = new SocketHandler(runningGame);
    socketHandler.startListening();

    if (pageType == 'new_game') {
        if (playerCount == 2) {
            $('#singlesButton').addClass('selected');
        } else {
            $('#doublesButton').addClass('selected');
        }

        NewGameFunctions.setUpNewGameEventHandlers();
        NewGameFunctions.displayForPlayerCount(playerCount);
        NewGameFunctions.updateScanPlayerButton($("#scanLabel"), playerCount, playerIdHash);
        NewGameFunctions.updateRankings();
        NewGameFunctions.updatePrediction();
    } else if (pageType == 'view_game') {
        socketHandler.updateScoreBars();
        let backgroundHandler = new BackgroundHandler();
        backgroundHandler.setUpBackground();
        NewGameFunctions.updatePrediction();
    }
});

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
 */

class SocketHandler {
  constructor() {
      window.dispatcher = new WebSocketRails(window.location.host + '/websocket');
  }

  updateScoreBars() {
      // update bars on page load
      RunningGameFunctions.scoreA($("#team_a_score").text());
      RunningGameFunctions.scoreB($("#team_b_score").text());
  }

  startListening() {
      let socketHandler = this;
      let roomId = $('#room-id').text();
    let channel = window.dispatcher.subscribe('room' + roomId);
    console.log(window.location.host + '/websocket');
    console.log('room' + roomId);

    dispatcher.bind('connection_closed', function() {
      console.log('Connection Lost!');
      let reconnect = setInterval(function(){
        if (window.dispatcher.state === 'connected') {
          console.log('Reconnected.');
          socketHandler.startListening();
          console.log('Requesting latest scores...');
          $.get('/api/rooms/' + roomId + '/send_current_scores'), function ( data ) {
            console.log(data);
          };
          clearInterval(reconnect);
        } else {
          console.log('Attempting to reconnect...');
          window.dispatcher = new WebSocketRails(window.location.host + '/websocket');
        }
      }, 5000);
    });

    channel.bind('team_a_score', function(score) {
      RunningGameFunctions.scoreA(score);
      $("#team_a_score").text(score);
      console.log(score);
    });
    channel.bind('team_b_score', function(score) {
      RunningGameFunctions.scoreB(score);
      $("#team_b_score").text(score);
      console.log(score);
    });
    channel.bind('user_scan_new', function(player_id) {
      window.location.replace("/rooms/" + roomId + "/game/new/players/create?player_id=" + player_id);
      console.log("Redirecting to create player " + player_id);
    });
    channel.bind('user_scan_existing', function(playerData) {
      console.log(playerData.image_url);
      let imageSelector = ".player_" + playerData.team + "_" + playerData.player_number + "_img";
      $(imageSelector).attr("src", playerData.image_url);
      NewGameFunctions.updatePlayerIdObject(playerData, playerIdHash);
      NewGameFunctions.updateScanPlayerButton($("#scanLabel"), playerCount, playerIdHash);
        NewGameFunctions.updatePrediction();
    });
    channel.bind('new_game_refresh', function() {
      location.reload();
    });
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

class RunningGameFunctions {
    static scoreA(score) {
        if (score === 'W') {
            console.log("TEAM A SCORE = W");
            $("#team_a_status").css({
                "background": 'url("/images/pong_assets/winner-animation.gif")',
                "background-size": "75%",
                "background-position": "center",
                "background-repeat": "no-repeat"
            });
            $("#b_meter").animate({width: "0%"});
            RunningGameFunctions.startContinueCountdown();
        } else if (score === 'G') {
            console.log("TEAM A SCORE = G");
            $("#b_meter").animate({width: (100 / 21) + "%"});

        } else if (score === 'D') {
            console.log("TEAM A SCORE = D");
            $("#b_meter").animate({width: "100%"});
            $("#b_meter").css({"background": "#ED1C24"});

        } else if (score === 'ADV') {
            console.log("TEAM A SCORE = ADV");
            $("#a_meter").animate({width: "100%"});
            $("#b_meter").animate({width: "50%"});
            $("#a_meter").css({"background": "#ED1C24"});
            $("#b_meter").css({"background": "#ED1C24"});

        } else {
            $("#team_a_status").text('\xa0');
            $("#b_meter").animate({width: ((21 - score) * 100 / 21) + "%"});
        }
    }

    static scoreB(score) {
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
    }

    static startContinueCountdown() {
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

    static isGameFull() {
        return (
            (playerCount == 2 && playerIdHash.a.length == 1 && playerIdHash.b.length == 1) ||
            (playerCount == 4 && playerIdHash.a.length == 2 && playerIdHash.b.length == 2)
        );
    }
}

/**
 * Initialize page on load
 */
$(document).ready( function() {
    console.log('rooms JS init');
    let socketHandler = new SocketHandler();
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
    } else if (pageType == 'view_game') {
        socketHandler.updateScoreBars();
        let backgroundHandler = new BackgroundHandler();
        backgroundHandler.setUpBackground();
    }
    NewGameFunctions.updatePrediction();
});
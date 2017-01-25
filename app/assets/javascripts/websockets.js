/**
 * @class
 * @property {RunningGameFunctions} runningGame
 */
class SocketHandler {
    /**
     * @param {RunningGameFunctions} runningGame
     */
    constructor(runningGame) {
        window.dispatcher = new WebSocketRails(window.location.host + '/websocket');
        this.runningGame = runningGame;
    }

    updateScoreBars() {
        // update bars on page load
        let teamAScore = $("#team_a_score").text();
        let teamBScore = $("#team_b_score").text();
        this.runningGame.audio.lastTeamAScore = teamAScore;
        this.runningGame.audio.lastTeamBScore = teamBScore;
        this.runningGame.scoreA(teamAScore);
        this.runningGame.scoreB(teamBScore);
    }

    startListening() {
        let socketHandler = this;
        let roomId = $('#room-id').text();
        let channel = window.dispatcher.subscribe('room' + roomId);
        let bathroomChannel = window.dispatcher.subscribe('bathroom' + roomId);
        console.log(window.location.host + '/websocket');
        console.log('room' + roomId);

        dispatcher.bind('connection_closed', function () {
            console.log('Connection Lost!');
            let reconnect = setInterval(function () {
                if (window.dispatcher.state === 'connected') {
                    console.log('Reconnected.');
                    socketHandler.startListening();
                    console.log('Requesting latest scores...');
                    $.get('/api/rooms/' + roomId + '/send_current_scores'), function (data) {
                        console.log(data);
                    };
                    clearInterval(reconnect);
                } else {
                    console.log('Attempting to reconnect...');
                    window.dispatcher = new WebSocketRails(window.location.host + '/websocket');
                }
            }, 5000);
        });

        channel.bind('score_update', function (score) {
            let {teamAScore, teamBScore} = score;
            socketHandler.runningGame.updateScore(teamAScore, teamBScore);
        });
        channel.bind('user_scan_new', function (player_id) {
            window.location.replace("/rooms/" + roomId + "/game/new/players/create?player_id=" + player_id);
            console.log("Redirecting to create player " + player_id);
        });
        channel.bind('user_scan_existing', function (playerData) {
            console.log(playerData.image_url);
            let imageSelector = ".player_" + playerData.team + "_" + playerData.player_number + "_img";
            $(imageSelector).attr("src", playerData.image_url);
            NewGameFunctions.updatePlayerIdObject(playerData, playerIdHash);
            NewGameFunctions.updateScanPlayerButton($("#scanLabel"), playerCount, playerIdHash);
            NewGameFunctions.updatePrediction();
            NewGameFunctions.updateRankings();
        });
        channel.bind('new_game_refresh', function () {
            location.reload();
        });

        bathroomChannel.bind('stall_update', function (bathroomData) {
            let bathroomFunctions = new BathroomFunctions();
            bathroomFunctions.updateBathroomStallStatus(bathroomData);
        });
    }
}
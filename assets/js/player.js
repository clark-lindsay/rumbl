const Player = {
  player: null,
  init(domId, playerId, onReady) {
    window.onYouTubeIframeAPIReady = () => {
      this.onIframeReady(domId, playerId, onReady);
    };
    const youtubeScriptTag = document.createElement("script");
    youtubeScriptTag.src = "//www.youtube.com/iframe_api";
    document.head.appendChild(youtubeScriptTag);
  },
  onIframeReady(domId, playerId, onReady) {
    this.player = new YT.Player(domId, {
      width: 360,
      height: 420,
      videoId: playerId,
      events: {
        onReady: (event) => onReady(event),
        onStateChange: (event) => this.onPlayerStateChange(event),
      },
    });
  },
  onPlayerStateChange(_event) {},
  getCurrentTime() {
    return Math.floor(this.player.getCurrentTime() * 1000);
  },
  seekTo(millSec) {
    return this.player.seekTo(millSec / 1000);
  },
};

export default Player;

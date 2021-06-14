import Player from "./player";

const Video = {
  init(socket, element) {
    if (!element) {
      return;
    }
    const playerId = element.getAttribute("data-player-id");
    const videoId = element.getAttribute("data-id");

    socket.connect();

    Player.init(video.id, playerId, () => {
      console.log("Player ready!");
      this.onReady(videoId, socket);
    });
  },

  onReady(videoId, socket) {
    const msgContainer = document.getElementById("msg-container");
    const msgInput = document.getElementById("msg-input");
    const postButton = document.getElementById("msg-submit");

    const videoChannel = socket.channel(`videos:${videoId}`);

    postButton.addEventListener("click", (_event) => {
      this.pushMessage(msgInput, videoChannel);
    });
    msgInput.addEventListener("keydown", (event) => {
      if (event.code === "Enter") {
        event.preventDefault();
        this.pushMessage(msgInput, videoChannel);
      }
    });

    videoChannel.on("new_annotation", (resp) => {
      this.renderAnnotation(msgContainer, resp);
    });

    videoChannel
      .join()
      .receive("ok", (resp) => {
        console.log("joined the video channel", resp);
      })
      .receive("error", (reason) => {
        console.log("join failed", reason);
      });
  },

  renderAnnotation(messageContainer, { user, body, at }) {
    const template = document.createElement("div");
    template.innerHTML = `
    <a href="#" data-seek=${this.escapeUserInput(at)}>
      <b>${this.escapeUserInput(user.username)}</b>: ${this.escapeUserInput(
      body
    )}
    </a>
    `;

    messageContainer.appendChild(template);
    messageContainer.scrollTop = messageContainer.scrollHeight;
  },

  escapeUserInput(str) {
    const div = document.createElement("div");
    div.appendChild(document.createTextNode(str));
    return div.innerHTML;
  },

  pushMessage(msgInputElement, channel) {
    const payload = {
      body: msgInputElement.value,
      at: Player.getCurrentTime(),
    };
    channel
      .push("new_annotation", payload)
      .receive("error", (error) => console.log(error));

    msgInputElement.value = "";
  },
};

export default Video;

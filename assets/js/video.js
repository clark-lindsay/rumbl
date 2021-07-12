import Player from "./player";
import { Presence } from "phoenix";

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
    const userList = document.getElementById("user-list");
    let lastSeenId = 0;

    const videoChannel = socket.channel(`videos:${videoId}`, () => {
      return { last_seen_id: lastSeenId };
    });

    const presence = new Presence(videoChannel);
    presence.onSync(() => {
      userList.innerHTML = presence
        .list((_id, { user, metas: [_first, ...rest] }) => {
          const sessionCount = rest.length + 1;
          return `<li>${user.username}: (${sessionCount}) </li>`;
        })
        .join("");
    });

    postButton.addEventListener("click", (_event) => {
      this.pushMessage(msgInput, videoChannel);
    });
    msgInput.addEventListener("keydown", (event) => {
      if (event.code === "Enter") {
        event.preventDefault();
        this.pushMessage(msgInput, videoChannel);
      }
    });

    msgContainer.addEventListener("click", (event) => {
      event.preventDefault();
      const timeInMilliseconds =
        event.target.getAttribute("data-seek") ||
        event.target.parentNode.getAttribute("data-seek");

      timeInMilliseconds ? Player.seekTo(timeInMilliseconds) : null;
    });

    videoChannel.on("new_annotation", (resp) => {
      lastSeenId = resp.id;
      this.renderAnnotation(msgContainer, resp);
    });

    videoChannel
      .join()
      .receive("ok", (resp) => {
        const ids = resp.annotations?.map((ann) => ann.id) ?? [];
        if (ids.length > 0) {
          lastSeenId = Math.max(...ids);
        }
        this.scheduleMessages(msgContainer, resp.annotations);
      })
      .receive("error", (reason) => {
        console.log("join failed", reason);
      });
  },

  scheduleMessages(msgContainer, annotations) {
    clearTimeout(this.scheduleTimer);
    this.scheduleTimer = setTimeout(() => {
      let currentTime = Math.floor(Player.getCurrentTime() / 1000);
      let remainingMessages = this.renderAtTime(
        msgContainer,
        currentTime,
        annotations
      );
      this.scheduleMessages(msgContainer, remainingMessages);
    }, 1000);
  },

  renderAtTime(msgContainer, timeInSeconds, annotations) {
    annotations
      .filter((ann) => {
        return msToSec(ann.at) <= timeInSeconds;
      })
      .forEach((ann) => {
        this.renderAnnotation(msgContainer, ann);
      });

    return annotations.filter((ann) => msToSec(ann.at) > timeInSeconds);
  },

  renderAnnotation(messageContainer, { user, body, at }) {
    const template = document.createElement("div");
    template.innerHTML = `
    <a href="#" data-seek=${this.escapeUserInput(at)}>
      [${this.formatTime(at)}]
      <b>${this.escapeUserInput(user.username)}</b>: ${this.escapeUserInput(
      body
    )}
    </a>
    `;

    messageContainer.appendChild(template);
    messageContainer.scrollTop = messageContainer.scrollHeight;
  },

  formatTime(timeInMilliseconds) {
    let date = new Date(null);
    date.setSeconds(msToSec(timeInMilliseconds));
    return date.toISOString().substr(14, 5);
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

function msToSec(timeInMillisecs) {
  return timeInMillisecs / 1000;
}

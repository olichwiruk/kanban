import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { authorId: Number }

  connect() {
    const currentUserId = document.querySelector('meta[name="current-user-id"]')?.content

    if (currentUserId && this.authorIdValue === parseInt(currentUserId)) {
      this.element.classList.add("chat-end")
    } else {
      this.element.classList.add("chat-start")
    }
  }
}

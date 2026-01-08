import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { url: String }

  connect() {
    this.sortable = new Sortable(this.element, {
      animation: 150,
      ghostClass: "sortable-ghost",
      chosenClass: "sortable-chosen",
      dragClass: "sortable-drag",
      handle: ".drag-handle",
      onEnd: (event) => {
        this.handleSort(event)
      }
    })
  }

  handleSort(_event) {
    this.sortLists()
  }

  sortLists() {
    const listIds = Array.from(this.element.children).map(el => el.dataset.id)

    fetch(this.urlValue, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ lists: listIds })
    })
  }

  disconnect() {
    if (!Sortable.active) this.sortable?.destroy()
  }
}

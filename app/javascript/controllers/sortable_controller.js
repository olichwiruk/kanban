import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = { group: String, url: String }

  connect() {
    this.sortable = new Sortable(this.element, {
      group: {
        name: this.groupValue,
        put: this.groupValue === "cards" ? ["cards"] : false
      },
      animation: 150,
      ghostClass: "sortable-ghost",
      chosenClass: "sortable-chosen",
      dragClass: "sortable-drag",
      handle: ".drag-handle",
      onStart: () => {
        if (this.groupValue === "cards") document.body.classList.add('dragging-card')
      },
      onEnd: (event) => {
        if (this.groupValue === "cards") document.body.classList.remove('dragging-card')
        this.handleSort(event)
      }
    })
  }

  handleSort(event) {
    if (this.groupValue === "lists") {
      this.sortLists()
    } else {
      this.sortCards(event)
    }
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

  sortCards(event) {
    const cardIds = Array.from(event.to.children).slice(1, -1).map(el => el.dataset.id)
    const cardId = event.item.dataset.id
    const listId = event.to.closest('[data-id]').dataset.id
    const position = cardIds.indexOf(cardId) + 1

    const url = this.urlValue.replace('CARD_ID', cardId)

    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ list_id: listId, position, card_ids: cardIds })
    })
  }

  disconnect() {
    if (!Sortable.active) this.sortable?.destroy()
  }
}

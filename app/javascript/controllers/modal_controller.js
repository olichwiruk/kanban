import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["dialog", "content"]
  static values = { url: String }

  open(event) {
    event.preventDefault()
    const url = event.currentTarget.dataset.modalUrlValue
    
    fetch(url)
      .then(response => response.text())
      .then(html => {
        this.contentTarget.innerHTML = html
        this.dialogTarget.showModal()
      })
      .catch(error => {
        console.error('Error loading card:', error)
      })
  }

  close() {
    this.dialogTarget.close()
  }
}

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [ "input" ]

  connect() {
    this.inputTarget.focus()
  }

  submit() {
    const value = this.inputTarget.value.trim()
    if (value.length > 0) {
      this.element.querySelector('form').requestSubmit()
    } else {
      this.cancel()
    }
  }

  cancel(event) {
    if (event) event.preventDefault()

    const frame = this.element.closest('turbo-frame')
    frame.src = null
    window.location.reload()
  }
}

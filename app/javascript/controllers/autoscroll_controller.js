import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.element.scrollTop = this.element.scrollHeight;
    this.observe();
  }

  observe() {
    this.observer = new MutationObserver(() => {
      this.handleScroll();
    });

    this.observer.observe(this.element, { childList: true });
  }

  disconnect() {
    this.observer.disconnect();
  }

  handleScroll() {
    const threshold = 150;
    const isAtBottom =
      this.element.scrollHeight - this.element.scrollTop <=
      this.element.clientHeight + threshold;

    if (isAtBottom) {
      this.scrollToBottom();
    }
  }

  scrollToBottom() {
    requestAnimationFrame(() => {
      this.element.scrollTo({
        top: this.element.scrollHeight,
        behavior: "smooth",
      });
    });
  }
}

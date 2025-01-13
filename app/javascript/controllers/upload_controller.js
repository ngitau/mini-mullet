import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["file", "form", "title", "message"];

  async upload(event) {
    event.preventDefault();
    const fileInput = this.fileTarget;
    const file = fileInput.files[0];

    this.titleTarget.hidden = true;

    if (!file) {
      this.messageTarget.textContent = "No file selected.";
      return;
    }

    const formData = new FormData();
    formData.append(fileInput.name, file);

    try {
      this.messageTarget.textContent = "Uploading...";
      const response = await fetch(this.formTarget.action, {
        method: "POST",
        body: formData,
        headers: {
          "Accept": "text/vnd.turbo-stream.html",
          "X-CSRF-Token": document.querySelector('meta[name="csrf-token"]').content,
        },
      });

      if (response.ok) {
        const turboStream = await response.text();
        document.body.insertAdjacentHTML("beforeend", turboStream);
      } else {
        this.messageTarget.textContent = "Upload failed, please try a different file.";
      }
    } catch (error) {
      this.messageTarget.textContent = "An error occurred while uploading.";
    }
  }
}

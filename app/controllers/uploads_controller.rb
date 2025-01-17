class UploadsController < ApplicationController
  # GET /uploads/new
  def new
    @upload = Upload.new
  end

  # POST /uploads
  def create
    @upload = Upload.new(file: upload_params[:file])
    @upload.process if @upload.valid?

    respond_to do |format|
      format.turbo_stream do
        if @upload.errors.present?
          render turbo_stream: turbo_stream.replace("upload_status", partial: "uploads/error")
        else
          render turbo_stream: turbo_stream.replace("upload", partial: "uploads/upload")
        end
      end
    end
  end

  private

  def upload_params
    params.expect(upload: [ :file ])
  end
end

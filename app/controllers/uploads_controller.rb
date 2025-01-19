class UploadsController < ApplicationController
  # GET /uploads/new
  def new
    @upload = Upload.new
  end

  # POST /uploads
  def create
    @upload = Upload.new(file: upload_params[:file])

    if @upload.save
      render turbo_stream: turbo_stream.replace("upload", partial: "uploads/upload")
    else
      render turbo_stream: turbo_stream.replace("upload_status", partial: "uploads/error")
    end
  end

  private

  def upload_params
    params.expect(upload: [ :file ])
  end
end

class FileUploadsController < ApplicationController
  include Rails.application.routes.url_helpers

  def create
    if params[:file].blank?
      return render json: { error: "No file to upload" }, status: :unprocessable_entity
    end

    file_upload = FileUpload.new
    file_upload.file.attach(params[:file])

    unless valid_file?(file_upload.file)
      return render json: { error: "Invalid file type or size" }, status: :unprocessable_entity
    end

    if file_upload.save
      render json: { message: "File uploaded successfully", url: url_for(file_upload.file) }, status: :created
    else
      render json: { error: "Failed to upload file" }, status: :unprocessable_entity
    end
  end

  def show
    file_upload = FileUpload.find(params[:id])
    if file_upload.file.attached?
      render json: { url: url_for(file_upload.file) }
    else
      render json: { error: "File not found" }, status: :not_found
    end
  end

  private

  def valid_file?(file)
    return false unless file.attached?

    allowed_types = ["text/plain", "image/png", "image/jpeg", "image/jpg", "application/pdf"]
    max_size = 5.megabytes

    allowed_types.include?(file.content_type) && file.byte_size <= max_size
  end
end

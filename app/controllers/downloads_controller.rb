# encoding: utf-8

#  Copyright (c) 2012-2016, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class DownloadsController < ApplicationController

  include AsyncDownload

  skip_before_action :authenticate_person!
  skip_authorization_check

  def show
    if downloadable?
      remove_async_download_cookie(params[:id])
      send_file filepath, x_sendfile: true
    else
      render 'errors/404', status: 404
    end
  end

  def exists?
    status = downloadable? ? 200 : 404

    respond_to do |format|
      format.json { render json: { status: status } }
    end
  end

  private

  def downloadable?
    return false unless filepath.to_s =~ /-(\w+?)\./
    File.exist?(filepath) &&
      filepath.to_s.match(/-(\w+?)\./)[1] == current_user.id.to_s
  end

  def filepath
    DOWNLOAD_DIRECTORY.join("#{params[:id]}.#{params[:file_type]}")
  end

end

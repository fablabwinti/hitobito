# encoding: utf-8

#  Copyright (c) 2012-2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

module AsyncDownload

  DOWNLOAD_DIRECTORY = ENV['DOWNLOAD_DIRECTORY'] || Rails.root.join('tmp', 'downloads').freeze

  ASYNC_DOWNLOADS_COOKIE = :async_downloads

  def set_download_cookies(filename, filetype)
    cookie_value = if async_downloads_cookie.present?
                     async_downloads_cookie << { name: filename, type: filetype }
                   else
                     [name: filename, type: filetype]
                   end

    cookies[ASYNC_DOWNLOADS_COOKIE] = { value: cookie_value.to_json, expires: 1.day.from_now }
  end

  def remove_async_download_cookie(name)
    if async_downloads_cookie && async_downloads_cookie.one?
      return cookies.delete ASYNC_DOWNLOADS_COOKIE
    end

    active_downloads = async_downloads_cookie.collect do |download|
      next if download['name'] == name
      download
    end.compact

    return unless active_downloads
    cookies[ASYNC_DOWNLOADS_COOKIE] = { value: active_downloads.to_json, expires: 1.day.from_now }
  end

  def download_filename(filename, person_id)
    "#{filename}_#{Time.now.to_i}-#{person_id}"
  end

  def async_downloads_cookie
    cookie_data = cookies[ASYNC_DOWNLOADS_COOKIE]
    return nil unless cookie_data
    JSON.parse(cookie_data)
  end

end

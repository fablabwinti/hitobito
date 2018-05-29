# encoding: utf-8

#  Copyright (c) 2012-2018, Jungwacht Blauring Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

require 'spec_helper'

describe DownloadsController do
  
  include AsyncDownload

  let(:person) { people(:bottom_member) }

  before do
    sign_in(person) 
  end

  context 'show' do
    it 'sends file deletes cookies if current_person has access and last download' do
      filename = download_filename('test', person.id)
      set_download_cookies(filename, 'txt')
      generate_test_file(filename)

      get :show, id: filename, file_type: 'txt'

      expect(response.body).to match('this is a testfile')
      expect(response.status).to match(200)
      expect(async_downloads_cookie).to be_nil
    end

    it 'sends file removes cookie entry if current_person has access and not last download' do
      filename = download_filename('test', person.id)
      set_download_cookies(filename, 'txt')
      set_download_cookies('second_download', 'txt')

      generate_test_file(filename)

      expect do
        get :show, id: filename, file_type: 'txt'
      end.to change { async_downloads_cookie.count }.by(-1)

      expect(response.body).to match('this is a testfile')
      expect(response.status).to match(200)
      expect(async_downloads_cookie).not_to be_nil
      expect(async_downloads_cookie).to be_one
      expect(async_downloads_cookie[0]['name']).not_to match(/^#{filename}/)
      expect(async_downloads_cookie[0]['name']).to match(/^second_download/)
    end

    it 'returns 404 if person has no access' do
      filename = download_filename('test', 1234) # random person_id
      generate_test_file(filename)

      get :show, id: filename, file_type: 'txt'

      is_expected.to render_template('errors/404')
      expect(response.status).to match(404)
    end

    it 'returns 404 if file does not exists' do
      get :show, id: 'unknown_file', file_type: 'txt'

      is_expected.to render_template('errors/404')
      expect(response.status).to match(404)
    end
  end

  context 'exist' do
    it 'render json status 200 if file exists and person has access' do
      filename = download_filename('test', person.id)
      generate_test_file(filename)

      get :exists?, id: filename, file_type: 'txt', format: :json

      json = JSON.parse(@response.body)
      expect(json['status']).to match(200)
    end

    it 'render json status 404 if person has no access' do
      filename = download_filename('test', 1234) # random person_id
      generate_test_file(filename)

      get :exists?, id: filename, file_type: 'txt', format: :json

      json = JSON.parse(@response.body)
      expect(json['status']).to match(404)
    end

    it 'render json status 404 if file does not exist' do
      get :exists?, id: 'unknown_file', file_type: 'txt', format: :json

      json = JSON.parse(@response.body)
      expect(json['status']).to match(404)
    end
  end

  private

  def generate_test_file(filename)
    File.write(
      AsyncDownload::DOWNLOAD_DIRECTORY.join("#{filename}.txt"),
      'this is a testfile'
    )
  end
end

# encoding: utf-8
# frozen_string_literal: true

#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class Export::ExportBaseJob < BaseJob

  include AsyncDownload

  PARAMETERS = [:locale, :format, :exporter, :filename].freeze

  attr_reader :exporter

  def perform
    set_locale
    export_file
  end

  def entries
    # override in sub class
  end

  def export_file
    File.write(
      DOWNLOAD_DIRECTORY.join("#{@filename}.#{@format}"),
      data
    )
  end

  def data
    exporter.export(@format, entries)
  end

end

# encoding: utf-8

#  Copyright (c) 2018, Pfadibewegung Schweiz. This file is part of
#  hitobito and licensed under the Affero General Public License version 3
#  or later. See the COPYING file at the top-level directory or at
#  https://github.com/hitobito/hitobito.

class Export::EventParticipationsExportJob < Export::ExportBaseJob

  self.parameters = PARAMETERS + [:event_id, :user_id, :controller_params]

  def initialize(format, event_id, user_id, controller_params, filename)
    super()
    @format = format
    @user_id = user_id
    @filename = filename
    @event_id = event_id
    @controller_params = controller_params
  end

  private

  def entries
    @entries ||= Event::ParticipationFilter.new(Event.find(@event_id),
                                                user,
                                                @controller_params).list_entries
  end

  def exporter
    if full_export?
      Export::Tabular::People::ParticipationsFull
    else
      Export::Tabular::People::ParticipationsAddress
    end
  end

  def full_export?
    # This condition has to be in the job because it loads all entries
    @controller_params[:details] && Ability.new(user).can?(:show_details, entries.first)
  end

  def user
    @user ||= Person.find(@user_id)
  end
end

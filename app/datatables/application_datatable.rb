class ApplicationDatatable
  delegate :params, to: :@view
  delegate :link_to, to: :@view
  delegate :content_tag, to: :@view
  delegate :current_user, to: :@view
  delegate :has_asset, to: :@view
  delegate :controller, to: :@view
  delegate :ordering_params, to: :controller

  def initialize(view)
    @view = view
  end

  def as_json(options = {})
    {
      recordsTotal: count,
      recordsFiltered: total_entries,
      data: data
    }
  end


  private

  def page
    params[:start].to_i / per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end

  def sort_column
    sort_columns[params[:order]['0'][:column].to_i]
  end

  def sort_direction
    params[:order]['0'][:dir] == "desc" ? "desc" : "asc"
  end

  def sort_symbol
    sort_direction == "asc" ? "+" : "-"
  end

  def sort_params
    sort_column.present? ? sort_column.split(",").map{|x| "#{sort_symbol}#{x}" }.join(",") : "+#{sort_columns[0]}"
  end
end

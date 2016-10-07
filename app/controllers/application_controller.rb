class ApplicationController < ActionController::API
  rescue_from QueryBuilderError, with: :handling_method
  protected

  def query_builder_error(error)
    render status: 400, json: {
        error: {
            message: error.message,
            invalid_params: error.invalid_params
        } }
  end

  def paginate(scope)
    paginator = Paginator.new(scope, request.query_parameters, current_url)
    response.headers['Link'] = paginator.links
    paginator.paginate
  end

  def current_url
    request.base_url + request.path
  end

  def sort(scope)
    Sorter.new(scope, params).sort
  end

  def filter(scope)
    Filter.new(scope, params.to_unsafe_hash).filter
  end

  def eager_load(scope)
    EagerLoader.new(scope, params).load
  end

  def orchestrate_query(scope, actions = :all)
    QueryOrchestrator.new(scope: scope,
                          params: params,
                          request: request,
                          response: response,
                          actions: actions).run
  end
end

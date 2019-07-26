module Api
  class CompaniesController < ApplicationController
    skip_before_action :authenticate, only: [:index, :show]

    # GET /api/companies
    def index
      authorize Company
      render json: Company.filter_flights(params[:filter]).order(:name)
    end

    # POST   /api/companies
    def create
      authorize Company
      company = Company.new(company_params)

      if company.save
        render json: company, status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    # GET    /api/companies/:id
    def show
      authorize Company
      company = Company.find(params[:id])
      render json: company
    end

    # PUT    /api/companies/:id
    def update
      company = Company.find(params[:id])
      authorize company

      if company.update(company_params)
        render json: company
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    # DELETE /api/companies/:id
    def destroy
      company = Company.find(params[:id])
      authorize company

      company.destroy
      head :no_content
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end

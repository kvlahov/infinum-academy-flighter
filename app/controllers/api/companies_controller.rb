module Api
  class CompaniesController < ApplicationController
    # GET /api/companies
    def index
      render json: Company.all
    end

    # POST   /api/companies
    def create
      authorize company

      company = Company.new(company_params)
      if company.save
        render json: company, status: :created
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    # GET    /api/companies/:id
    def show
      company = Company.find(params[:id])
      render json: company
    end

    # PUT    /api/companies/:id
    def update
      authorize company

      company = Company.find(params[:id])
      if company.update(company_params)
        render json: company
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    # DELETE /api/companies/:id
    def destroy
      authorize company

      Company.find(params[:id]).destroy
      head :no_content
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end

module Api
  class CompaniesController < ApplicationController
    # GET /api/companies
    def index
      render json: Company.all, each_serializer: CompanySerializer
    end

    # POST   /api/companies
    def create
      company = Company.new(company_params)
      if company.save
        render json: company, status: :created
      else
        render json: { errors: user.error }, status: :bad_request
      end
    end

    # GET    /api/companies/:id
    def show
      company = Company.find(params[:id])
      render json: company, serializer: CompanySerializer, status: :ok
    end

    # PUT    /api/companies/:id
    def update
      company = Company.find(params[:id])
      if company.update(company_params)
        render json: company, status: :ok
      else
        render json: { errors: company.errors }, status: :bad_request
      end
    end

    # DELETE /api/companies/:id
    def destroy
      company = Company.find(params[:id])
      company.destroy
      render json: {}, status: :no_content
    end

    private

    def company_params
      params.require(:company).permit(:name)
    end
  end
end

class CoursesController < ApplicationController

  def index
    @courses = Course.includes(
      {:assignments => [:submissions, :flat_curve, :linear_curve]}
      ).where("teacher_id = ?", current_teacher.id)
  end

  def show
    @course = Course.includes( { :students => :submissions}, { :assignments => [:submissions, :flat_curve, :linear_curve] }).find(params[:id])
  end

  def create
    @course = current_teacher.courses.build(course_params)
    respond_to do |format|
      if @course.save
        format.json {render json: @course, include: [{students: {include: :submissions}}, {assignments: {include: :submissions}}]}
      else
        format.json { render json: {errors: @course.errors.full_messages },
                                    :status => 422}
      end
    end
  end

  def update
    @course = Course.find(params[:id])
    respond_to do |format|
      if @course.update(course_params)
        format.json {render json: @course, include: [{students: {include: :submissions}}, {assignments: {include: :submissions}}]}
      else
        format.json { render json: {errors: @course.errors.full_messages },
                                    :status => 422}
      end
    end
  end

  def destroy
    @course = current_teacher.courses.find_by_id(params[:id])
    course = @course
    if @course && @course.destroy
      respond_to do |format|
        format.json { render json: @course, status: 200 }
      end
    end
  end

  private

  def course_params
    params.require(:course).permit(:title, :start_date, :end_date, :meeting_days)
  end

end

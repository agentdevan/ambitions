import { Task } from "../domain/models";

export interface TaskRepository {
  listTasks(): Promise<Task[]>;
  listTasksForDate(date: string): Promise<Task[]>;
  saveTasks(tasks: Task[]): Promise<void>;
}

import { z } from 'zod'

export const UserSchema = z.object({
  id: z.number(),
  name: z.string(),
  email: z.email(),
  role_name: z.string(),
})
export type UserRecode = z.infer<typeof UserSchema>

export interface IConsumerRepository {
  getUser(id: number): Promise<UserRecode | null>
}

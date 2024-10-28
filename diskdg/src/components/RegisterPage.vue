<script setup>
import * as z from "zod";
import { fromZodError } from "zod-validation-error";
import { ref } from "vue";

const form = ref({
  username: "",
  email: "",
  password: "",
  passwordConfirmation: "",
});

const formSchema = z
  .object({
    username: z
      .string()
      .min(3, { message: "Username needs to be at least 3 characters" })
      .max(30, { message: "Username cannot exceed 30 characters" }),
    email: z.string().email({ message: "Invalid email address" }),
    password: z
      .string()
      .min(6, { message: "Password must be at least 6 characters long" }),
    passwordConfirmation: z
      .string()
      .min(6, { message: "Password confirmation must be at least 6 characters long" }),
  })
  .refine((data) => data.password === data.passwordConfirmation, {
    path: ["passwordConfirmation"],
    message: "Passwords do not match",
  });

const errors = ref(null);

const onSubmit = (event) => {
  console.log("event", event);
  const valid = formSchema.safeParse(form.value);
  if (!valid.success) {
    errors.value = valid.error.format();
    const formattedError = fromZodError(valid.error, {});
    console.log("formattedError", formattedError);
  } else {
    errors.value = null;
  }
};
</script>

<template>
  <div class="w-full max-w-lg bg-white p-8 rounded shadow-lg">
    <h1 class="text-3xl">Register</h1>
    <form @submit.prevent="onSubmit" class="flex flex-col">
      <label for="username">Username</label>
      <input
        id="username"
        v-model="form.username"
        class="input"
        placeholder="Username"
        type="text"
      />
      <div v-if="errors?.username" class="text-red-800">
        <span v-for="error in errors?.username?._errors" :key="error"> {{ error }}</span>
      </div>

      <label for="email">Email</label>
      <input
        id="email"
        v-model="form.email"
        class="input"
        placeholder="Email"
        type="email"
      />
      <div v-if="errors?.email" class="text-red-800">
        <span v-for="error in errors?.email?._errors" :key="error"> {{ error }}</span>
      </div>

      <label for="password">Password</label>
      <input
        id="password"
        v-model="form.password"
        class="input"
        placeholder="Password"
        type="password"
      />
      <div v-if="errors?.password" class="text-red-800">
        <span v-for="error in errors?.password?._errors" :key="error"> {{ error }}</span>
      </div>

      <label for="passwordConfirmation">Confirm Password</label>
      <input
        id="passwordConfirmation"
        v-model="form.passwordConfirmation"
        class="input"
        placeholder="Confirm Password"
        type="password"
      />
      <div v-if="errors?.passwordConfirmation" class="text-red-800">
        <span v-for="error in errors?.passwordConfirmation?._errors" :key="error"> {{ error }}</span>
      </div>

      <button
        class="p-4 border-solid text-white border-2 bg-green-500 rounded hover:bg-green-900"
        type="submit"
      >
        Register
      </button>
    </form>
  </div>
</template>

<style scoped></style>

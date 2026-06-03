#BUILD STAGE

FROM node:20-alpine AS builder

#WORKDIR
WORKDIR /app

#Copying the package files
COPY package*.json ./

#Clean install dependencies
RUN npm ci

#Copy the rest of the source code
COPY . .

#Run the typescript compiler
RUN npm run build


#PRODUCTION STAGE
FROM  node:20-alpine AS production

#Set NODE_ENV 
ENV NODE_ENV=production

#WORKDIR
WORKDIR /app

#Copying the package files
COPY package*.json ./

#Install only production dependencies
RUN npm ci --only=production

#Copy the built files from the builder stage
COPY --from=builder /app/dist ./dist

#Create a non-root user and switch to it
RUN addgroup -S appuser && adduser -S appuser -G appuser

#Set ownership of the app directory to the non-root user
RUN chown -R appuser:appuser /app

USER appuser

#Expose the application port
EXPOSE 3000

#Start the application
CMD ["node", "dist/server.js"]
